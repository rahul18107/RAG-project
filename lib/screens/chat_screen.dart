import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../models/document.dart';
import '../models/message.dart';
import '../widgets/chat/chat_bubble.dart';
import '../widgets/chat/chat_input_bar.dart';
import '../widgets/chat/chat_doc_selector.dart';
import '../services/rag_service.dart';
import '../services/document_service.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});


  @override
  State<ChatScreen> createState() => _ChatScreenState();

}

class _ChatScreenState extends State<ChatScreen>
    with AutomaticKeepAliveClientMixin{
  final _scrollController = ScrollController();
  String? _selectedDocId;
  List<Message> _messages = [];
  bool _isTyping = false;

  @override
  bool get wantKeepAlive => true;
  List<Document> _docs = [];

  Future<void> _loadDocs() async {
    final docs = await DocumentService.fetchAll();
    setState(() {
      _docs = docs;
      if (docs.isNotEmpty && _selectedDocId == null) {
        _selectedDocId = docs.first.id;
      }
    });
    // load messages for selected doc
    if (_selectedDocId != null) {
      await _loadMessages(_selectedDocId!);
    }
  }

  Future<void> _loadMessages(String documentId) async {
    final msgs = await DocumentService.fetchMessages(documentId);
    setState(() {
      _messages = msgs.map((m) => Message(
        id: m['id'],
        text: m['text'],
        isUser: m['is_user'],
        sentAt: DateTime.parse(m['created_at']),
        sourceRef: m['source_ref'],
      )).toList();
    });
    _scrollToBottom();
  }

  @override
  void initState() {
    super.initState();
    _loadDocs();
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: AppColors.cardDark,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _handleSend(String text) async {
    if (_selectedDocId == null) {
      _showSnack( 'Please select a document first');
      return;
    }

    // add user message to UI
    setState(() {
      _messages.add(Message(
        id: DateTime.now().toIso8601String(),
        text: text,
        isUser: true,
        sentAt: DateTime.now(),
      ));
      _isTyping = true;
    });
    _scrollToBottom();

    // save user message to supabase
    await DocumentService.saveMessage(
      documentId: _selectedDocId!,
      text: text,
      isUser: true,
    );

    try {
      final result = await RagService.askQuestion(
        question: text,
        documentId: _selectedDocId!,
      );

      final aiText = result['answer'] ?? 'Could not generate a response.';
      final source = result['source'];

      // add AI message to UI
      setState(() {
        _isTyping = false;
        _messages.add(Message(
          id: DateTime.now().toIso8601String(),
          text: aiText,
          isUser: false,
          sentAt: DateTime.now(),
          sourceRef: source,
        ));
      });
      _scrollToBottom();

      // save AI message to supabase
      await DocumentService.saveMessage(
        documentId: _selectedDocId!,
        text: aiText,
        isUser: false,
        sourceRef: source,
      );

    } catch (e) {
      setState(() => _isTyping = false);
      _showSnack( 'Error: $e');
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Document? get _selectedDoc => _docs
      .where((d) => d.id == _selectedDocId)
      .firstOrNull;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // top bar
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Chat',
                            style: AppTextStyles.screenTitle),
                        if (_selectedDoc != null)
                          Text(
                            _selectedDoc!.name,
                            style: AppTextStyles.cardMeta,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // doc selector chips
            ChatDocSelector(
              documents: _docs,
              selectedId: _selectedDocId,
              onSelect: (id) {
                setState(() => _selectedDocId = id);
                _loadMessages(id);
              }
            ),

            const SizedBox(height: 20),

            // messages
            Expanded(
              child: _messages.isEmpty
                  ? _EmptyState(docName: _selectedDoc?.name)
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16),
                      itemCount:
                          _messages.length + (_isTyping ? 1 : 0),
                      itemBuilder: (_, i) {
                        if (_isTyping && i == _messages.length) {
                          return const _TypingIndicator();
                        }
                        return ChatBubble(
                            message: _messages[i]);
                      },
                    ),
            ),

            // input
            ChatInputBar(onSend: _handleSend),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String? docName;
  const _EmptyState({this.docName});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64, height: 64,
            decoration: const BoxDecoration(
              color: AppColors.card,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.chat_bubble_outline,
                size: 28, color: AppColors.textMuted),
          ),
          const SizedBox(height: 16),
          const Text('Ask anything about your notes',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
                fontFamily: 'DMSans',
              )),
          const SizedBox(height: 6),
          Text(
            docName != null
                ? 'Currently loaded: $docName'
                : 'Select a document above',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textMuted,
              fontFamily: 'DMSans',
            ),
          ),
        ],
      ),
    );
  }
}

class _TypingIndicator extends StatelessWidget {
  const _TypingIndicator();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                _dot(0),
                const SizedBox(width: 4),
                _dot(150),
                const SizedBox(width: 4),
                _dot(300),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _dot(int delayMs) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOut,
      builder: (_, val, _) => Container(
        width: 6, height: 6,
        decoration: BoxDecoration(
          color: AppColors.textMuted
              .withOpacity(0.4 + (val * 0.6)),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
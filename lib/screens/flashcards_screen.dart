import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../models/flashcard.dart';
import '../widgets/flashcards/flashcard_card.dart';

import '../widgets/flashcards/flashcard_generate_btn.dart';
import '../services/document_service.dart';
import '../services/rag_service.dart';
import '../models/document.dart';

class FlashcardsScreen extends StatefulWidget {
  const FlashcardsScreen({super.key});



  @override
  State<FlashcardsScreen> createState() => _FlashcardsScreenState();


}






class _FlashcardsScreenState extends State<FlashcardsScreen> {
  List<Document> _docs = [];
  String? _selectedDocId;
  bool _generating = false;
  List<Flashcard> _realCards = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }


  Future<void> _loadData() async {
    final docs = await DocumentService.fetchAll();
    setState(() {
      _docs = docs;
      if (docs.isNotEmpty) _selectedDocId = docs.first.id;
    });
    if (_selectedDocId != null) {
      await _loadFlashcards(_selectedDocId!);
    }
  }

  Future<void> _loadFlashcards(String documentId) async {
    final cards = await DocumentService.fetchFlashcards(documentId);
    setState(() {
      _realCards = cards.map((c) => Flashcard(
        id: c['id'],
        topic: c['topic'],
        title: c['title'],
        points: List<String>.from(c['points']),
        subject: c['subject'],
        pageRef: c['page_ref'] ?? '',
      )).toList();
    });
  }



  Future<void> _handleGenerate() async {
    if (_selectedDocId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select a document first'),
          backgroundColor: AppColors.cardDark,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    setState(() => _generating = true);

    try {
      final doc = _docs.firstWhere((d) => d.id == _selectedDocId);
      final cards = await RagService.generateFlashcards(
        documentId: _selectedDocId!,
        subject: doc.subject,

      );

      setState(() {
        _realCards = cards.map((c) => Flashcard(
          id: DateTime.now().toIso8601String(),
          topic: c['topic'],
          title: c['title'],
          points: List<String>.from(c['points']),
          subject: doc.subject,
          pageRef: c['page_ref'] ?? '',
        )).toList();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${_realCards.length} cards generated!'),
          backgroundColor: AppColors.cardDark,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed: $e'),
          backgroundColor: AppColors.cardDark,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
        ),
      );
    } finally {
      setState(() => _generating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // top bar
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Flashcards',
                          style: AppTextStyles.screenTitle),
                      Text(
                        '${_realCards.length} cards',
                        style: AppTextStyles.cardMeta,
                      ),
                    ],
                  ),
                  // stats pill
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.bookmark_outline,
                            size: 13,
                            color: AppColors.textMuted),
                        const SizedBox(width: 4),
                        Text(
                          '${_realCards.length} total',
                          style: AppTextStyles.cardMeta,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // doc selector
            SizedBox(
              height: 38,
              child: _docs.isEmpty
                  ? const Center(
                child: Text('No documents uploaded yet',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textMuted,
                      fontFamily: 'DMSans',
                    )),
              )
                  : ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _docs.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final doc = _docs[i];
                  final isSelected = doc.id == _selectedDocId;
                  return GestureDetector(
                    onTap: () {
                      setState(() => _selectedDocId = doc.id);
                      _loadFlashcards(doc.id);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.cardDark
                            : AppColors.card,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        doc.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'DMSans',
                          color: isSelected
                              ? AppColors.card
                              : AppColors.textMuted,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),



// keep your existing subject chips below this
            // subject filter chips

            // cards list
            Expanded(
              child: _generating
                  ? const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
                        color: AppColors.cardDark),
                    SizedBox(height: 16),
                    Text('Generating flashcards...',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textMuted,
                          fontFamily: 'DMSans',
                        )),
                  ],
                ),
              )
                  : _realCards.isEmpty
                  ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.style_outlined,
                        size: 48, color: AppColors.textHint),
                    const SizedBox(height: 16),
                    const Text('No flashcards yet',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                          fontFamily: 'DMSans',
                        )),
                    const SizedBox(height: 6),
                    const Text('Tap Generate to create cards from your notes',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textMuted,
                          fontFamily: 'DMSans',
                        )),
                    const SizedBox(height: 24),
                    FlashcardGenerateBtn(onTap: _handleGenerate),
                  ],
                ),
              )
                  : ListView.builder(
                physics: const BouncingScrollPhysics(),
                itemCount: _realCards.length + 1,
                itemBuilder: (_, i) {
                  if (i == _realCards.length) {
                    return FlashcardGenerateBtn(
                        onTap: _handleGenerate);
                  }
                  return FlashcardCard(
                    card: _realCards[i],
                    isDark: i == 0,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
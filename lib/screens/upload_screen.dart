import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../core/theme.dart';

import '../services/pdf_service.dart';
import '../services/rag_service.dart';

import '../widgets/upload/upload_dropzone.dart';

import '../widgets/home/document_card.dart';
import 'package:provider/provider.dart';
import '../providers/document_provider.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {

  bool _loading = false;
  bool _uploading = false;
  String _uploadStatus = '';

  @override
  void initState() {
    super.initState();
    _loadDocs();
  }

  Future<void> _loadDocs() async {
    setState(() => _loading = true);
    try {
      await context.read<DocumentProvider>().loadDocs();
    } catch (e) {
      _showSnack('Failed to load documents: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _handleUpload() async {
    // step 1: pick PDF
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      allowMultiple: false,
    );

    if (result == null || result.files.isEmpty) return;
    final file = result.files.first;
    if (file.path == null) return;

    // step 2: pick subject
    final subject = await _showSubjectPicker();
    if (subject == null) return;

    setState(() {
      _uploading = true;
      _uploadStatus = 'Reading PDF...';
    });

    try {
      // step 3: extract text
      setState(() => _uploadStatus = 'Extracting text...');
      final text = await PdfService.extractText(file.path!);

      if (text.isEmpty) {
        _showSnack('Could not extract text from this PDF');
        return;
      }

      // step 4: get file info
      final pageCount = await PdfService.getPageCount(file.path!);
      final fileSize = PdfService.formatFileSize(
          File(file.path!).lengthSync());

      // step 5: chunk + embed + store
      setState(() => _uploadStatus = 'Generating embeddings...');
      await RagService.storeDocument(
        name: file.name.replaceAll('.pdf', ''),
        subject: subject,
        content: text,
        pageCount: pageCount,
        fileSize: fileSize,
      );

      _showSnack('✓ Uploaded successfully!');
      await _loadDocs();
    } catch (e) {
      _showSnack('Upload failed: $e');
    } finally {
      setState(() {
        _uploading = false;
        _uploadStatus = '';
      });
    }
  }

  Future<String?> _showSubjectPicker() async {
    final controller = TextEditingController();
    final suggestions = ['DBMS', 'OS', 'Maths', 'Networks', 'DSA', 'COA'];
    String? selected;

    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          StatefulBuilder(
            builder: (context, setModalState) =>
                Container(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery
                        .of(context)
                        .viewInsets
                        .bottom + 20,
                    left: 20, right: 20, top: 24,
                  ),
                  decoration: const BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.vertical(
                        top: Radius.circular(24)),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Select Subject',
                          style: AppTextStyles.screenTitle),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 8, runSpacing: 8,
                        children: suggestions.map((s) {
                          final isSelected = selected == s;
                          return GestureDetector(
                            onTap: () {
                              setModalState(() => selected = s);
                              controller.text = s;
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 10),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.cardDark
                                    : AppColors.card,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(s,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'DMSans',
                                    color: isSelected
                                        ? AppColors.card
                                        : AppColors.textMuted,
                                  )),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: TextField(
                          controller: controller,
                          onChanged: (v) =>
                              setModalState(() => selected = v),
                          style: const TextStyle(
                            fontSize: 13,
                            fontFamily: 'DMSans',
                            color: AppColors.textPrimary,
                          ),
                          decoration: const InputDecoration(
                            hintText: 'Or type a custom subject...',
                            hintStyle: TextStyle(
                              fontSize: 13,
                              color: AppColors.textHint,
                              fontFamily: 'DMSans',
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 14),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      GestureDetector(
                        onTap: () {
                          final s = controller.text.trim();
                          if (s.isNotEmpty) Navigator.pop(context, s);
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: AppColors.cardDark,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Center(
                            child: Text('Confirm',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.card,
                                  fontFamily: 'DMSans',
                                )),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
          ),
    );
  }

  Future<void> _handleDelete(String id) async {
    try {
      await context.read<DocumentProvider>().deleteDoc(id);
      _showSnack('Document deleted');
    } catch (e) {
      _showSnack('Delete failed: $e');
    }
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

  @override
  Widget build(BuildContext context) {
    final docs = context.watch<DocumentProvider>().docs;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // top bar
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Upload',
                      style: AppTextStyles.screenTitle),
                  GestureDetector(
                    onTap: _uploading ? null : _handleUpload,
                    child: Container(
                      width: 46, height: 46,
                      decoration: const BoxDecoration(
                        color: AppColors.cardDark,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.add,
                          color: AppColors.card, size: 22),
                    ),
                  ),
                ],
              ),
            ),

            // upload progress
            if (_uploading)
              Container(
                margin: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 4),
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.cardDark,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const SizedBox(
                      width: 16, height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.card,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded( // ← prevents text overflow too
                      child: Text(_uploadStatus,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.card,
                            fontFamily: 'DMSans',
                          )),
                    ),
                  ],
                ),
              ),

            SizedBox(
              child: UploadDropzone(
                  onTap: _uploading ? () {} : _handleUpload),
            ),

            // docs list — this is scrollable
            Expanded(
              child: _loading
                  ? const Center(
                  child: CircularProgressIndicator(
                      color: AppColors.cardDark))
                  : docs.isEmpty
                  ? const Center(
                child: Text(
                  'No documents yet\nTap + to upload a PDF',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textMuted,
                    fontFamily: 'DMSans',
                    height: 1.6,
                  ),
                ),
              )
                  : RefreshIndicator(
                onRefresh: _loadDocs,
                color: AppColors.cardDark,
                child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: docs.length,
                  itemBuilder: (_, i) =>
                      DocumentCard(
                        document: docs[i],
                        isActive: i == 0,
                        onTap: () {},
                        onDelete: () => _handleDelete(docs[i].id),

                      ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

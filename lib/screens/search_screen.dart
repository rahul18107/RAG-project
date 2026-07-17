import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../models/document.dart';
import '../widgets/home/document_card.dart';

class SearchScreen extends StatefulWidget {
  final List<Document> documents;
  const SearchScreen({super.key, required this.documents});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // keyword search: every word typed must appear in the
  // document name, subject or meta (case-insensitive)
  List<Document> get _results {
    final keywords = _query
        .toLowerCase()
        .split(' ')
        .where((w) => w.isNotEmpty)
        .toList();
    if (keywords.isEmpty) return widget.documents;

    return widget.documents.where((doc) {
      final haystack =
          '${doc.name} ${doc.subject} ${doc.meta}'.toLowerCase();
      return keywords.every(haystack.contains);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final results = _results;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // top bar: back + search field
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 46, height: 46,
                      decoration: const BoxDecoration(
                        color: AppColors.card,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_back,
                          size: 20, color: AppColors.textPrimary),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      autofocus: true,
                      onChanged: (v) => setState(() => _query = v),
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textPrimary,
                        fontFamily: 'DMSans',
                      ),
                      decoration: InputDecoration(
                        hintText: 'Search documents…',
                        hintStyle: const TextStyle(
                          color: AppColors.textHint,
                          fontSize: 14,
                        ),
                        prefixIcon: const Icon(Icons.search,
                            size: 20, color: AppColors.textMuted),
                        suffixIcon: _query.isEmpty
                            ? null
                            : IconButton(
                                icon: const Icon(Icons.close,
                                    size: 18,
                                    color: AppColors.textMuted),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() => _query = '');
                                },
                              ),
                        filled: true,
                        fillColor: AppColors.card,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(23),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // result count
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
              child: Text(
                _query.isEmpty
                    ? 'ALL DOCUMENTS'
                    : '${results.length} RESULT${results.length == 1 ? '' : 'S'}',
                style: AppTextStyles.sectionLabel,
              ),
            ),

            // results
            Expanded(
              child: results.isEmpty
                  ? const _NoResults()
                  : ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.only(bottom: 20),
                      itemCount: results.length,
                      itemBuilder: (_, i) =>
                          DocumentCard(document: results[i]),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NoResults extends StatelessWidget {
  const _NoResults();

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
            child: const Icon(Icons.search_off,
                size: 28, color: AppColors.textMuted),
          ),
          const SizedBox(height: 16),
          const Text('No documents found',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
                fontFamily: 'DMSans',
              )),
          const SizedBox(height: 6),
          const Text(
            'Try a different keyword',
            style: TextStyle(
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

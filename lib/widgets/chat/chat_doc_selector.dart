import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../models/document.dart';

class ChatDocSelector extends StatelessWidget {
  final List<Document> documents;
  final String? selectedId;
  final Function(String) onSelect;

  const ChatDocSelector({
    super.key,
    required this.documents,
    required this.selectedId,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: documents.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final doc = documents[i];
          final isSelected = doc.id == selectedId;
          return GestureDetector(
            onTap: () => onSelect(doc.id),
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
              child: Padding(
                padding: const EdgeInsets.only(top: 3.5),
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
            ),
          );
        },
      ),
    );
  }
}
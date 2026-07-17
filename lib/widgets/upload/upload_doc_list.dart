import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../models/document.dart';

class UploadDocList extends StatelessWidget {
  final List<Document> documents;
  final Function(String id) onDelete;

  const UploadDocList({
    super.key,
    required this.documents,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 10, 20, 8),
          child: Text('ALL DOCUMENTS',
              style: AppTextStyles.sectionLabel),
        ),
        ...documents.asMap().entries.map(
              (entry) => _DocRow(
            doc: entry.value,
            onDelete: () => onDelete(entry.value.id),
            isActive: entry.key == 0,
          ),
        ),
      ],
    );
  }
}

class _DocRow extends StatelessWidget {
  final Document doc;
  final VoidCallback onDelete;
  final bool isActive;

  const _DocRow({required this.doc, required this.onDelete,this.isActive= false,});

  @override
  Widget build(BuildContext context) {
    return Container(
      
      margin: const EdgeInsets.symmetric(
          horizontal: 16, vertical: 5),
      padding: const EdgeInsets.symmetric(
          horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isActive
            ? AppColors.cardDark
            : AppColors.card,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          // icon
          Container(
            width: 100, height: 144,
            decoration: BoxDecoration(
              color: isActive
                  ? AppColors.cardDark
                  : AppColors.card,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.insert_drive_file_outlined,
                size: 18, color: AppColors.textMuted),
          ),
          const SizedBox(width: 12),
          // name + meta
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(doc.name,
                    style: AppTextStyles.cardTitle.copyWith(color: isActive
                        ? Colors.white
                        : AppColors.textPrimary,),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),

                const SizedBox(height: 3),
                Text('${doc.timeAgo} · ${doc.meta}',
                    style: AppTextStyles.cardMeta),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // subject tag
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.tag,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(doc.subject,
                style: AppTextStyles.tagText),
          ),
          const SizedBox(width: 8),
          // delete button
          GestureDetector(
            onTap: onDelete,
            child: Container(
              width: 30, height: 30,
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.close,
                  size: 14, color: AppColors.textMuted),
            ),
          ),
        ],
      ),
    );
  }
}
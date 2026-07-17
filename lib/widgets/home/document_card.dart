import 'package:flutter/material.dart';
import '../../models/document.dart';
import '../../core/theme.dart';

class DocumentCard extends StatelessWidget {
  final Document document;
  final VoidCallback? onDelete;
  final bool isActive;
  final VoidCallback? onTap;


  const DocumentCard({
    super.key,
    required this.document,
    this.onDelete,
    this.isActive = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bg    = isActive ? AppColors.cardDark : AppColors.card;
    final fg    = isActive ? AppColors.card     : AppColors.textPrimary;
    final meta  = isActive ? AppColors.textHint : AppColors.textMuted;
    final tagBg = isActive ? const Color(0xFF333333) : AppColors.tag;
    final tagFg = isActive ? const Color(0xFFAAAAAA) : AppColors.textMuted;
    final iconC = isActive ? AppColors.card     : AppColors.textMuted;

    return GestureDetector(
      onTap: onTap,
      child: Container(
       
        margin: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 5),
        padding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            Container(
              width: 100, height: 144,
              decoration: BoxDecoration(
                color: isActive
                    ? const Color(0xFF333333)
                    : AppColors.background,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.insert_drive_file_outlined,
                  size: 20, color: iconC),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(document.name,
                      style: AppTextStyles.cardTitle
                          .copyWith(color: fg),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text(document.meta,
                      style: AppTextStyles.cardMeta
                          .copyWith(color: meta)),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: tagBg,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(document.subject,
                  style: AppTextStyles.tagText
                      .copyWith(color: tagFg)),
            ),
            const SizedBox(width: 8),

            if (onDelete != null)
              GestureDetector(
                onTap: onDelete,
                child: Container(
                  width: 28, height: 28,
                  decoration: BoxDecoration(
                    color: isActive
                        ? const Color(0xFF333333)
                        : AppColors.background,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.close,
                    size: 13,
                    color: isActive
                        ? AppColors.textHint
                        : AppColors.textMuted,
                  ),
                ),
              ),
            // delete button


          ],

        ),
      ),
    );
  }
}
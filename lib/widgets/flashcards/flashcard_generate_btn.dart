import 'package:flutter/material.dart';
import '../../core/theme.dart';

class FlashcardGenerateBtn extends StatelessWidget {
  final VoidCallback onTap;

  const FlashcardGenerateBtn({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 4, 16, 12),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.cardDark,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bolt, color: AppColors.card, size: 16),
            SizedBox(width: 8),
            Text(
              'Generate summary cards',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.card,
                fontFamily: 'DMSans',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
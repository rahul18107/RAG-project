import 'package:flutter/material.dart';
import '../../core/theme.dart';

class UploadDropzone extends StatelessWidget {
  final VoidCallback onTap;

  const UploadDropzone({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 400,height: 200,
        margin: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 25),
        padding: const EdgeInsets.symmetric(vertical: 28),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFFCCCCCC),
            width: 1.5,
            strokeAlign: BorderSide.strokeAlignInside,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 15.0),
              child: Container(
                width: 52, height: 52,
                decoration: const BoxDecoration(
                  color: AppColors.cardDark,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.upload_file_outlined,
                    color: AppColors.card, size: 22),
              ),
            ),
            const SizedBox(height: 12),
            const Text('Tap to upload PDF',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                  fontFamily: 'DMSans',
                )),
            const SizedBox(height: 4),
            const Text('Notes, textbooks, slides',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textMuted,
                  fontFamily: 'DMSans',
                )),
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import '../../core/theme.dart';

class CustomBottomNavigation extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
      height: 72,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildItem(Icons.home_outlined, "Home", 0),
          _buildItem(Icons.upload_outlined, "Upload", 1),
          _buildItem(Icons.chat_bubble_outline, "Chat", 2),
          _buildItem(Icons.desktop_windows_outlined, "Cards", 3),
        ],
      ),
    );
  }

  Widget _buildItem(IconData icon, String label, int index) {
    final bool isSelected = currentIndex == index;

    return GestureDetector(
      onTap: () => onTap(index),
      child: SizedBox(
        width: 60,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected
                  ? AppColors.textPrimary
                  : AppColors.textHint,
              size: 24,
            ),

            const SizedBox(height: 4),

            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: isSelected
                    ? AppColors.textPrimary
                    : AppColors.textHint,
              ),
            ),

            const SizedBox(height: 3),

            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 4,
              height: 4,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.textPrimary
                    : Colors.transparent,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
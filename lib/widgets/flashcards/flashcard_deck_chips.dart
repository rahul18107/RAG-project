import 'package:flutter/material.dart';
import '../../core/theme.dart';

class FlashcardDeckChips extends StatelessWidget {
  final List<String> subjects;
  final String selected;
  final Function(String) onSelect;

  const FlashcardDeckChips({
    super.key,
    required this.subjects,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final all = ['All', ...subjects];
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: all.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final label = all[i];
          final isSelected = label == selected;
          return GestureDetector(
            onTap: () => onSelect(label),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.cardDark
                    : AppColors.card,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                label,
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
    );
  }
}
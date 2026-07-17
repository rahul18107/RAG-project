import 'package:flutter/material.dart';
import '../../core/theme.dart';

class HomeStatsRow extends StatelessWidget {
  final int subjects;
  final int docs;
  final int chats;
  final int cards;

  const HomeStatsRow({
    super.key,
    required this.subjects,
    required this.docs,
    required this.chats,
    required this.cards,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _StatBox(label: 'Subjects', value: subjects),
          const SizedBox(width: 10),
          _StatBox(label: 'Docs',     value: docs),
          const SizedBox(width: 10),
          _StatBox(label: 'Chats',    value: chats),
          const SizedBox(width: 10),
          _StatBox(label: 'Cards',    value: cards),
        ],
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final int value;
  const _StatBox({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: 10, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$value', style: AppTextStyles.statNumber),
            const SizedBox(height: 4),
            Text(label.toUpperCase(),
                style: AppTextStyles.statLabel),
          ],
        ),
      ),
    );
  }
}
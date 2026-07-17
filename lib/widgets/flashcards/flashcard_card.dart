import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../models/flashcard.dart';

class FlashcardCard extends StatefulWidget {
  final Flashcard card;
  final bool isDark;

  const FlashcardCard({
    super.key,
    required this.card,
    this.isDark = false,
  });

  @override
  State<FlashcardCard> createState() => _FlashcardCardState();
}

class _FlashcardCardState extends State<FlashcardCard> {
  bool _bookmarked = false;

  @override
  Widget build(BuildContext context) {
    final bg       = widget.isDark ? AppColors.cardDark : AppColors.card;
    final fg       = widget.isDark ? AppColors.card : AppColors.textPrimary;
    final topicClr = widget.isDark ? const Color(0xFF666666) : AppColors.textMuted;
    final metaClr  = widget.isDark ? const Color(0xFF888888) : AppColors.textMuted;
    final dotClr   = widget.isDark ? AppColors.card : AppColors.cardDark;
    final pointClr = widget.isDark ? const Color(0xFFBBBBBB) : const Color(0xFF444444);
    final divClr   = widget.isDark ? const Color(0xFF222222) : const Color(0xFFF0F0F0);
    final bkBg     = widget.isDark ? const Color(0xFF222222) : AppColors.background;
    final bkIcClr  = _bookmarked
        ? (widget.isDark ? AppColors.card : AppColors.cardDark)
        : (widget.isDark ? const Color(0xFF555555) : AppColors.textHint);

    return Container(
      margin: const EdgeInsets.symmetric(
          horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // topic label
          Text(
            '${widget.card.subject} · ${widget.card.topic}'.toUpperCase(),
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              color: topicClr,
              fontFamily: 'DMSans',
            ),
          ),
          const SizedBox(height: 6),

          // title
          Text(
            widget.card.title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
              color: fg,
              fontFamily: 'DMSans',
            ),
          ),
          const SizedBox(height: 12),

          // bullet points
          ...widget.card.points.map((point) => Padding(
                padding: const EdgeInsets.only(bottom: 7),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Container(
                        width: 5, height: 5,
                        decoration: BoxDecoration(
                          color: dotClr,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        point,
                        style: TextStyle(
                          fontSize: 12,
                          height: 1.5,
                          color: pointClr,
                          fontFamily: 'DMSans',
                        ),
                      ),
                    ),
                  ],
                ),
              )),

          // divider
          Divider(color: divClr, height: 20),

          // footer
          Row(
            children: [
              Icon(Icons.insert_drive_file_outlined,
                  size: 12, color: metaClr),
              const SizedBox(width: 4),
              Text(
                widget.card.pageRef,
                style: TextStyle(
                  fontSize: 10,
                  color: metaClr,
                  fontFamily: 'DMSans',
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () =>
                    setState(() => _bookmarked = !_bookmarked),
                child: Container(
                  width: 28, height: 28,
                  decoration: BoxDecoration(
                    color: bkBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _bookmarked
                        ? Icons.bookmark
                        : Icons.bookmark_outline,
                    size: 14,
                    color: bkIcClr,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
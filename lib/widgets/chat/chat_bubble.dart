import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../models/message.dart';

class ChatBubble extends StatelessWidget {
  final Message message;

  const ChatBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;

    return Padding(
      padding: EdgeInsets.only(
        left:   isUser ? 60 : 0,
        right:  isUser ? 0  : 60,
        bottom: 10,
      ),
      child: Column(
        crossAxisAlignment: isUser
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 11),
            decoration: BoxDecoration(
              color: isUser
                  ? AppColors.cardDark
                  : AppColors.card,
              borderRadius: BorderRadius.only(
                topLeft:     const Radius.circular(16),
                topRight:    const Radius.circular(16),
                bottomLeft:  Radius.circular(isUser ? 16 : 4),
                bottomRight: Radius.circular(isUser ? 4  : 16),
              ),
            ),
            child: Text(
              message.text,
              style: TextStyle(
                fontSize: 13,
                height: 1.5,
                color: isUser
                    ? AppColors.card
                    : AppColors.textPrimary,
                fontFamily: 'DMSans',
              ),
            ),
          ),
          if (message.sourceRef != null) ...[
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.insert_drive_file_outlined,
                    size: 11, color: AppColors.textHint),
                const SizedBox(width: 3),
                Text(
                  message.sourceRef!,
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.textHint,
                    fontFamily: 'DMSans',
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
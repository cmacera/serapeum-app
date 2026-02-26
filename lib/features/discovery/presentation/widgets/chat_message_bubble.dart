import 'package:flutter/material.dart';

class ChatMessageBubble extends StatelessWidget {
  final String text;
  final bool isUser;

  const ChatMessageBubble({
    super.key,
    required this.text,
    required this.isUser,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Row(
        mainAxisAlignment: isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: isUser
                    ? Theme.of(context).cardColor
                    : const Color(0xFF930DF2).withValues(alpha: 0.2),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16.0),
                  topRight: const Radius.circular(16.0),
                  bottomLeft: Radius.circular(isUser ? 16.0 : 4.0),
                  bottomRight: Radius.circular(isUser ? 4.0 : 16.0),
                ),
              ),
              child: Text(
                text,
                style: TextStyle(color: isUser ? Colors.white : Colors.white70),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

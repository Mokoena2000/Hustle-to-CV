import 'package:flutter/material.dart';
import '../models/user_model.dart';

class ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const ChatBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            CircleAvatar(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              child: const Icon(Icons.smart_toy, size: 16),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: message.isUser 
                  ? CrossAxisAlignment.end 
                  : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: message.isUser 
                        ? Colors.green[100] 
                        : Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(message.text),
                ),
                const SizedBox(height: 4),
                Text(
                  message.isUser ? 'You' : 'CV Assistant',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          if (message.isUser) ...[
            const SizedBox(width: 12),
            CircleAvatar(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              child: const Icon(Icons.person, size: 16),
            ),
          ],
        ],
      ),
    );
  }
}
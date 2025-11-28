class User {
  final String id;
  final String email;
  final String name;
  final List<String> savedBulletPoints;

  User({
    required this.id,
    required this.email,
    required this.name,
    this.savedBulletPoints = const [],
  });
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}

// New class to track conversation history for AI context
class ConversationManager {
  final List<Map<String, String>> _history = [];

  void addMessage(String role, String content) {
    _history.add({
      'role': role,
      'content': content,
    });
    
    // Keep only last 10 messages to manage token usage
    if (_history.length > 10) {
      _history.removeAt(0);
    }
  }

  List<Map<String, String>> get history => List.from(_history);
  
  void clear() {
    _history.clear();
  }
}
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
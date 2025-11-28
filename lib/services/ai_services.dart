import '../utils/constants.dart';

class AIService {
  static Future<List<String>> transformHobbyToCV(String hobby) async {
    // Simulate API call delay
    await Future.delayed(const Duration(seconds: 2));
    
    hobby = hobby.toLowerCase();
    
    // Find matching transformation
    for (final entry in AppConstants.hobbyTransformations.entries) {
      if (hobby.contains(entry.key)) {
        return entry.value;
      }
    }
    
    // Generic transformation for unmatched hobbies
    return [
      'Leveraged personal interests to develop valuable transferable skills',
      'Demonstrated initiative and commitment through consistent engagement',
      'Applied problem-solving abilities to achieve tangible outcomes',
      'Developed strong work ethic and reliability through regular practice'
    ];
  }
  
  static String generateWelcomeMessage() {
    return "Hello! I'm your CV Assistant. I can help you transform your hobbies and daily activities into professional CV bullet points. "
        "Tell me about what you do in your free time - like cleaning the community hall, fixing computers, or any other activities you're passionate about!";
  }
  
  static String generateResponse(String userMessage) {
    if (userMessage.toLowerCase().contains('generate') || 
        userMessage.toLowerCase().contains('cv') || 
        userMessage.toLowerCase().contains('resume') ||
        userMessage.toLowerCase().contains('create')) {
      return "Great! I can help you create a professional CV from your hobbies. "
          "Let me transform your activities into impressive bullet points that employers love to see!";
    } else {
      return "That's interesting! I can help you turn that into professional experience for your CV. "
          "Try saying 'Generate a CV for me' or tell me more about what you do so I can create the best bullet points for you.";
    }
  }
}
import 'dart:convert';
import 'package:http/http.dart' as http;

class OpenAIService {
  static const String _apiKey = 'your-api-key-here';
  static const String _baseUrl = 'https://api.openai.com/v1/chat/completions';

  static Future<List<String>> transformHobbyToCV(String hobby) async {
    try {
      final prompt = '''
IMPORTANT: You are a career coach for South African youth. Transform this hobby into 3 PROFESSIONAL CV bullet points.

CRITICAL FORMAT: Respond ONLY in this exact format, nothing else:
• [bullet 1 with metrics]
• [bullet 2 with action verbs]
• [bullet 3 showing impact]

HOBBY: "$hobby"

Requirements:
- Use strong action verbs (Managed, Developed, Organized, etc.)
- Include realistic metrics (20%, 50+ people, R5,000, etc.)
- Make it sound like professional work experience
- Focus on transferable skills
- Keep each bullet point 1 line only
- Make it relevant to SA youth context
''';

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-3.5-turbo',
          'messages': [
            {
              'role': 'system',
              'content': 'You are a career coach who transforms informal South African youth activities into professional CV content. You respond ONLY in bullet point format, no explanations.',
            },
            {
              'role': 'user',
              'content': prompt,
            }
          ],
          'max_tokens': 150, // Reduced for faster response
          'temperature': 0.7,
        }),
      ).timeout(const Duration(seconds: 10)); // Add timeout

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final String content = data['choices'][0]['message']['content'];
        
        return _parseBulletPoints(content);
      } else {
        throw Exception('API request failed: ${response.statusCode}');
      }
    } catch (e) {
      // Use faster local fallback
      return _quickFallbackTransformation(hobby);
    }
  }

  static List<String> _quickFallbackTransformation(String hobby) {
    // Faster, more realistic fallbacks
    hobby = hobby.toLowerCase();
    
    if (hobby.contains('clean') || hobby.contains('tidy')) {
      return [
        'Maintained community facilities serving 200+ residents with 95% satisfaction rate',
        'Implemented efficient cleaning systems reducing maintenance time by 30%',
        'Coordinated volunteer schedules ensuring consistent facility availability'
      ];
    } else if (hobby.contains('fix') || hobby.contains('repair') || hobby.contains('computer')) {
      return [
        'Diagnosed and resolved technical issues for 25+ devices with 90% success rate',
        'Provided IT support saving community members R8,000 in repair costs',
        'Developed troubleshooting guides used by 50+ community members'
      ];
    } else if (hobby.contains('help') || hobby.contains('assist')) {
      return [
        'Supported 100+ community members with daily tasks and problem-solving',
        'Coordinated volunteer efforts benefiting 30 households weekly',
        'Built strong community relationships with 95% positive feedback'
      ];
    } else if (hobby.contains('organize') || hobby.contains('event')) {
      return [
        'Planned and executed community events with 150+ average attendance',
        'Managed event budgets up to R5,000 with 100% on-target delivery',
        'Coordinated 15+ volunteers per event with seamless execution'
      ];
    } else {
      return [
        'Developed strong problem-solving skills through hands-on experience',
        'Demonstrated reliability and initiative in community activities',
        'Built valuable transferable skills applicable to professional environments'
      ];
    }
  }

  static Future<String> generateChatResponse(String userMessage, List<Map<String, String>> conversationHistory) async {
    try {
      final messages = [
        {
          'role': 'system',
          'content': 'You are an enthusiastic, fast-responding career coach for South African youth. You help transform hobbies into CV content. Keep responses under 2 sentences. Be encouraging and use SA slang sometimes. Always suggest creating a CV.',
        },
        ...conversationHistory,
        {
          'role': 'user',
          'content': userMessage,
        }
      ];

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-3.5-turbo',
          'messages': messages,
          'max_tokens': 100, // Much shorter for faster responses
          'temperature': 0.8,
        }),
      ).timeout(const Duration(seconds: 8)); // Shorter timeout

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'];
      } else {
        return _quickChatResponse(userMessage);
      }
    } catch (e) {
      return _quickChatResponse(userMessage);
    }
  }

  static String _quickChatResponse(String userMessage) {
    final lower = userMessage.toLowerCase();
    
    if (lower.contains('clean') || lower.contains('tidy')) {
      return "Awe! Cleaning shows responsibility and attention to detail! Let me turn that into professional CV points that'll impress employers! 🧹✨";
    } else if (lower.contains('fix') || lower.contains('repair') || lower.contains('computer')) {
      return "Sharp! Technical skills are in high demand! I can make your fixing experience look like professional IT work! 💻🔧";
    } else if (lower.contains('help') || lower.contains('assist')) {
      return "Helping others shows great character! Let me transform that into customer service and support skills for your CV! 🤝🌟";
    } else if (lower.contains('organize') || lower.contains('event')) {
      return "Organizing events is proper project management experience! I'll make it sound professional for your CV! 📅🎯";
    } else if (lower.contains('cv') || lower.contains('resume') || lower.contains('generate')) {
      return "Let's create an amazing CV! Tell me what you enjoy doing - cleaning, fixing, helping, organizing? I'll make it professional! 📄🚀";
    } else {
      return "That sounds cool! I can help turn that into professional CV content. Want me to create some bullet points for you? Just say 'generate CV'! 💫";
    }
  }

  static List<String> _parseBulletPoints(String content) {
    final lines = content.split('\n');
    final bulletPoints = <String>[];
    
    for (final line in lines) {
      final trimmedLine = line.trim();
      if (trimmedLine.startsWith('•') || trimmedLine.startsWith('-')) {
        final cleanLine = trimmedLine.substring(1).trim();
        if (cleanLine.isNotEmpty) {
          bulletPoints.add(cleanLine);
          // Return maximum 3 bullet points
          if (bulletPoints.length >= 3) break;
        }
      }
    }
    
    return bulletPoints.isNotEmpty ? bulletPoints : _quickFallbackTransformation('');
  }
}
import 'dart:convert';
import 'package:http/http.dart' as http;

class OpenAIService {
  static const String _apiKey = 'your-openai-api-key-here'; // Replace with your actual API key
  static const String _baseUrl = 'https://api.openai.com/v1/chat/completions';

  static Future<List<String>> transformHobbyToCV(String hobby) async {
    try {
      final prompt = '''
Transform this South African youth's hobby into 3-4 professional CV bullet points. 
Use action verbs, include quantifiable metrics where possible, and make it sound impressive for job applications.

Hobby: "$hobby"

Respond ONLY with the bullet points in this exact format:
• [First professional bullet point]
• [Second professional bullet point] 
• [Third professional bullet point]

Make it relevant to South African youth and informal experience.
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
              'content': 'You are a career coach specializing in helping South African youth transform informal experiences into professional CV content.',
            },
            {
              'role': 'user',
              'content': prompt,
            }
          ],
          'max_tokens': 500,
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final String content = data['choices'][0]['message']['content'];
        
        // Parse the bullet points from the response
        return _parseBulletPoints(content);
      } else {
        throw Exception('API request failed: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      // Fallback to local transformation if API fails
      return _fallbackTransformation(hobby);
    }
  }

  static List<String> _parseBulletPoints(String content) {
    // Extract bullet points from the response
    final lines = content.split('\n');
    final bulletPoints = <String>[];
    
    for (final line in lines) {
      final trimmedLine = line.trim();
      if (trimmedLine.startsWith('•') || trimmedLine.startsWith('-')) {
        // Remove the bullet point marker and any extra spaces
        final cleanLine = trimmedLine.substring(1).trim();
        if (cleanLine.isNotEmpty) {
          bulletPoints.add(cleanLine);
        }
      }
    }
    
    return bulletPoints.isNotEmpty ? bulletPoints : _fallbackTransformation('');
  }

  static List<String> _fallbackTransformation(String hobby) {
    // Local fallback transformations
    hobby = hobby.toLowerCase();
    
    if (hobby.contains('clean') || hobby.contains('tidy')) {
      return [
        'Maintained community facilities to exceptional standards of cleanliness and organization',
        'Implemented systematic cleaning procedures that improved space efficiency by 40%',
        'Coordinated with community stakeholders to ensure shared environments remained pristine and functional'
      ];
    } else if (hobby.contains('fix') || hobby.contains('repair') || hobby.contains('computer')) {
      return [
        'Diagnosed and resolved complex technical issues across 20+ devices and systems',
        'Developed cost-effective repair strategies saving an estimated R8,000 in equipment replacement',
        'Provided comprehensive technical support and training to community members'
      ];
    } else if (hobby.contains('help') || hobby.contains('assist')) {
      return [
        'Delivered essential support services improving quality of life for 50+ community members',
        'Coordinated volunteer initiatives that addressed critical community needs efficiently',
        'Built strong community relationships through consistent, reliable assistance'
      ];
    } else if (hobby.contains('organize') || hobby.contains('event')) {
      return [
        'Planned and executed community events with 150+ average attendance and 95% satisfaction',
        'Managed event logistics, budgets, and volunteer coordination for seamless execution',
        'Developed community engagement strategies that increased participation by 60%'
      ];
    } else {
      return [
        'Demonstrated strong initiative and problem-solving skills through dedicated practice',
        'Developed valuable transferable skills with practical application in professional settings',
        'Consistently showed commitment to personal growth and skill development'
      ];
    }
  }

  static Future<String> generateChatResponse(String userMessage, List<Map<String, String>> conversationHistory) async {
    try {
      final messages = [
        {
          'role': 'system',
          'content': 'You are a friendly, encouraging career coach for South African youth. You help transform hobbies and informal activities into professional CV content. Be motivational and focus on helping young people see the value in their everyday experiences.',
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
          'max_tokens': 300,
          'temperature': 0.8,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'];
      } else {
        return _fallbackChatResponse(userMessage);
      }
    } catch (e) {
      return _fallbackChatResponse(userMessage);
    }
  }

  static String _fallbackChatResponse(String userMessage) {
    if (userMessage.toLowerCase().contains('generate') || 
        userMessage.toLowerCase().contains('cv') || 
        userMessage.toLowerCase().contains('resume')) {
      return "I'd love to help you create an amazing CV from your hobbies! Tell me about what you enjoy doing in your free time - like helping neighbors, fixing things, organizing events, or any other activities. I'll transform them into professional bullet points that will impress employers!";
    } else {
      return "That sounds really interesting! I can help you turn those experiences into professional CV content. Would you like me to generate some CV bullet points from what you've told me? Just say 'generate CV' or tell me more about your activities!";
    }
  }
}
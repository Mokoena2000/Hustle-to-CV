import 'package:flutter/material.dart';
import 'cv_generation_page.dart';
import '../models/user_model.dart';
import '../services/ai_services.dart';
import '../utils/constants.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/quick_action_chip.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final TextEditingController _chatController = TextEditingController();
  final List<ChatMessage> _messages = [];
  final ConversationManager _conversationManager = ConversationManager();
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    final welcomeMessage = AIService.generateWelcomeMessage();
    _addBotMessage(welcomeMessage);
    _conversationManager.addMessage('assistant', welcomeMessage);
  }

  void _addBotMessage(String text) {
    setState(() {
      _messages.add(ChatMessage(
        text: text, 
        isUser: false, 
        timestamp: DateTime.now()
      ));
    });
  }

  void _addUserMessage(String text) {
    setState(() {
      _messages.add(ChatMessage(
        text: text, 
        isUser: true, 
        timestamp: DateTime.now()
      ));
    });
    _conversationManager.addMessage('user', text);
  }

  void _sendMessage() async {
    final text = _chatController.text.trim();
    if (text.isEmpty) return;

    _chatController.clear();
    _addUserMessage(text);
    setState(() {
      _isTyping = true;
    });

    try {
      final response = await AIService.generateChatResponse(
        text, 
        _conversationManager.history
      );
      
      _addBotMessage(response);
      _conversationManager.addMessage('assistant', response);

      // Check if we should navigate to CV generation
      if (_shouldNavigateToCVGeneration(text, response)) {
        await Future.delayed(const Duration(seconds: 1));
        _navigateToCVGeneration(text);
      }
    } catch (e) {
      _addBotMessage("I encountered an issue, but I can still help you create amazing CV content! Try telling me about your hobbies directly.");
    } finally {
      setState(() {
        _isTyping = false;
      });
    }
  }

  bool _shouldNavigateToCVGeneration(String userMessage, String botResponse) {
    final userLower = userMessage.toLowerCase();
    final botLower = botResponse.toLowerCase();
    
    return userLower.contains('generate') || 
           userLower.contains('cv') || 
           userLower.contains('resume') ||
           userLower.contains('create') ||
           botLower.contains('generate') ||
           (userLower.contains('hobby') && botLower.contains('cv')) ||
           _isDirectHobbyDescription(userMessage);
  }

  bool _isDirectHobbyDescription(String message) {
    final hobbyKeywords = [
      'clean', 'fix', 'help', 'organize', 'teach', 'manage', 
      'create', 'build', 'repair', 'maintain', 'coordinate',
      'garden', 'sport', 'coach', 'volunteer', 'community'
    ];
    return hobbyKeywords.any((keyword) => message.toLowerCase().contains(keyword));
  }

  void _navigateToCVGeneration(String userInput) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CVGenerationPage(initialInput: userInput),
      ),
    );
  }

  void _quickAction(String hobby) {
    _chatController.text = "I want to create a CV from my experience: $hobby";
    _sendMessage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hustle to CV'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Profile page coming soon!')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.lightbulb_outline),
            onPressed: () {
              _quickAction("helping my community with various tasks");
            },
            tooltip: 'Get inspired',
          ),
        ],
      ),
      body: Column(
        children: [
          // Quick actions for common hobbies
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.green[50],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Quick Start - Common SA Youth Activities:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[800],
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: AppConstants.quickActions
                      .map((action) => QuickActionChip(
                            text: action,
                            onPressed: () => _quickAction(action),
                          ))
                      .toList(),
                ),
              ],
            ),
          ),
          
          // Chat messages
          Expanded(
            child: ListView.builder(
              reverse: true,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (_isTyping && index == 0) {
                  return _buildTypingIndicator();
                }
                final messageIndex = _isTyping ? index - 1 : index;
                final message = _messages[messageIndex];
                return ChatBubble(message: message);
              },
            ),
          ),
          
          // Input area
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey[300]!)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _chatController,
                    decoration: InputDecoration(
                      hintText: 'Tell me about your hobbies and I\'ll make them CV-ready...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  child: IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.green,
            child: const Icon(Icons.smart_toy, color: Colors.white, size: 16),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'CV Coach',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
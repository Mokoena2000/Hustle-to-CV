import 'package:flutter/material.dart';
import 'cv_generation_page.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
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
    _addWelcomeMessages();
  }

  void _addWelcomeMessages() {
    final welcomeMessages = [
      "Hey! I'm your CV Coach! 🚀",
      "I help South African youth turn everyday activities into professional CV gold!",
      "Tell me what you enjoy doing - like cleaning, fixing things, helping others, or organizing events!",
      "I'll transform it into impressive bullet points that employers love! 💼"
    ];

    // Stagger the welcome messages for better UX
    for (int i = 0; i < welcomeMessages.length; i++) {
      Future.delayed(Duration(milliseconds: i * 800), () {
        if (mounted) {
          _addBotMessage(welcomeMessages[i]);
          _conversationManager.addMessage('assistant', welcomeMessages[i]);
        }
      });
    }
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
    
    // Immediate UI feedback
    setState(() {
      _isTyping = true;
    });

    // Quick response for common phrases
    if (_isDirectHobbyRequest(text)) {
      await Future.delayed(const Duration(milliseconds: 500));
      _handleDirectHobby(text);
      return;
    }

    try {
      final response = await OpenAIService.generateChatResponse(
        text, 
        _conversationManager.history
      );
      
      _addBotMessage(response);
      _conversationManager.addMessage('assistant', response);

      // Quick navigation for CV requests
      if (_shouldNavigateToCVGeneration(text, response)) {
        await Future.delayed(const Duration(milliseconds: 800));
        _navigateToCVGeneration(text);
      }
    } catch (e) {
      _addBotMessage("Let me help you create an amazing CV! What do you enjoy doing in your community?");
    } finally {
      setState(() {
        _isTyping = false;
      });
    }
  }

  bool _isDirectHobbyRequest(String message) {
    final directHobbies = [
      'clean', 'fix', 'help', 'organize', 'teach', 'manage', 
      'repair', 'garden', 'sport', 'coach', 'volunteer'
    ];
    return directHobbies.any((hobby) => message.toLowerCase().contains(hobby));
  }

  void _handleDirectHobby(String message) {
    final lower = message.toLowerCase();
    String response = "";
    
    if (lower.contains('clean')) {
      response = "Awe! Cleaning shows amazing responsibility! 🧹 Let me turn that into professional CV points!";
    } else if (lower.contains('fix')) {
      response = "Sharp! Technical skills are in high demand! 💻 Let me make your experience look professional!";
    } else if (lower.contains('help')) {
      response = "Helping others shows great character! 🤝 I can transform that into customer service skills!";
    } else if (lower.contains('organize')) {
      response = "Organizing is proper project management! 📅 Let me make it shine on your CV!";
    } else {
      response = "That's awesome! I can help turn that into professional CV content. Ready to create some bullet points?";
    }
    
    _addBotMessage(response);
    _conversationManager.addMessage('assistant', response);
    
    // Auto-navigate after short delay
    Future.delayed(const Duration(milliseconds: 1200), () {
      _navigateToCVGeneration(message);
    });
    
    setState(() {
      _isTyping = false;
    });
  }

  bool _shouldNavigateToCVGeneration(String userMessage, String botResponse) {
    final userLower = userMessage.toLowerCase();
    return userLower.contains('generate') || 
           userLower.contains('cv') || 
           userLower.contains('resume') ||
           userLower.contains('create') ||
           _isDirectHobbyRequest(userMessage);
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
    _chatController.text = "I $hobby";
    _sendMessage();
  }

  void _fastTrackCV(String hobby) {
    _navigateToCVGeneration("I $hobby");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hustle to CV'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.bolt),
            onSelected: (value) => _fastTrackCV(value),
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'clean the community hall', child: Text('🚀 Fast Track: Cleaning')),
              const PopupMenuItem(value: 'fix computers and phones', child: Text('🚀 Fast Track: Fixing')),
              const PopupMenuItem(value: 'help neighbors and community', child: Text('🚀 Fast Track: Helping')),
              const PopupMenuItem(value: 'organize community events', child: Text('🚀 Fast Track: Organizing')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Enhanced quick actions
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.green[50],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.bolt, color: Colors.green[800], size: 20),
                    const SizedBox(width: 4),
                    Text(
                      'Quick Start - Tap Any Activity:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[800],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: AppConstants.quickActions
                      .map((action) => ActionChip(
                            label: Text(action),
                            onPressed: () => _quickAction(action),
                            backgroundColor: Colors.green[100],
                            labelStyle: TextStyle(
                              color: Colors.green[800],
                              fontWeight: FontWeight.w500,
                            ),
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
          
          // Enhanced input area
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
                      hintText: 'What do you enjoy doing? I\'ll make it CV-ready...',
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
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: _isTyping ? 48 : 48,
                  height: 48,
                  child: CircleAvatar(
                    backgroundColor: _isTyping ? Colors.green : Colors.green,
                    foregroundColor: Colors.white,
                    child: _isTyping
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : IconButton(
                            icon: const Icon(Icons.rocket_launch),
                            onPressed: _sendMessage,
                          ),
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
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  margin: const EdgeInsets.symmetric(horizontal: 1),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                Container(
                  width: 6,
                  height: 6,
                  margin: const EdgeInsets.symmetric(horizontal: 1),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                Container(
                  width: 6,
                  height: 6,
                  margin: const EdgeInsets.symmetric(horizontal: 1),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
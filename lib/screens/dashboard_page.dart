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
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _addBotMessage(AIService.generateWelcomeMessage());
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
  }

  void _sendMessage() async {
    final text = _chatController.text.trim();
    if (text.isEmpty) return;

    _chatController.clear();
    _addUserMessage(text);
    setState(() {
      _isTyping = true;
    });

    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isTyping = false;
    });

    if (text.toLowerCase().contains('generate') || 
        text.toLowerCase().contains('cv') || 
        text.toLowerCase().contains('resume') ||
        text.toLowerCase().contains('create')) {
      _addBotMessage(AIService.generateResponse(text));
      
      await Future.delayed(const Duration(seconds: 1));
      _navigateToCVGeneration(text);
    } else {
      _addBotMessage(AIService.generateResponse(text));
    }
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
                  'Quick Start:',
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
                      hintText: 'Tell me about your hobbies...',
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
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.green,
            child: Icon(Icons.smart_toy, color: Colors.white, size: 16),
          ),
          SizedBox(width: 12),
          Text('CV Assistant is thinking...'),
        ],
      ),
    );
  }
}
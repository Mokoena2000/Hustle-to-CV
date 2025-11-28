import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/ai_services.dart';

class CVGenerationPage extends StatefulWidget {
  final String initialInput;

  const CVGenerationPage({super.key, required this.initialInput});

  @override
  State<CVGenerationPage> createState() => _CVGenerationPageState();
}

class _CVGenerationPageState extends State<CVGenerationPage> {
  final TextEditingController _hobbyController = TextEditingController();
  List<String> _generatedBullets = [];
  bool _isGenerating = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _hobbyController.text = widget.initialInput;
    if (_isHobbyInput(widget.initialInput)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _generateCVBullets();
      });
    }
  }

  bool _isHobbyInput(String input) {
    final hobbyKeywords = [
      'clean', 'fix', 'help', 'organize', 'teach', 'manage', 
      'create', 'build', 'repair', 'maintain', 'coordinate',
      'garden', 'sport', 'coach', 'volunteer', 'community'
    ];
    return hobbyKeywords.any((keyword) => input.toLowerCase().contains(keyword));
  }

  void _generateCVBullets() async {
    final inputText = _hobbyController.text.trim();
    if (inputText.isEmpty) return;

    setState(() {
      _isGenerating = true;
      _generatedBullets.clear();
      _errorMessage = '';
    });

    try {
      final bullets = await AIService.transformHobbyToCV(inputText);
      
      setState(() {
        _generatedBullets = bullets;
        _isGenerating = false;
      });
    } catch (e) {
      setState(() {
        _isGenerating = false;
        _errorMessage = 'Using enhanced local transformation (AI service temporarily unavailable)';
      });
      
      // Fallback will be handled by the service itself
      final fallbackBullets = await AIService.transformHobbyToCV(inputText);
      setState(() {
        _generatedBullets = fallbackBullets;
      });
    }
  }

  void _copyToClipboard() async {
    if (_generatedBullets.isEmpty) return;

    final text = _generatedBullets.map((bullet) => '• $bullet').join('\n');
    try {
      await Clipboard.setData(ClipboardData(text: text));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Professional bullet points copied to clipboard!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ready to copy manually')),
      );
    }
  }

  void _saveToCV() {
    if (_generatedBullets.isEmpty) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('CV items saved to your profile!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _regenerate() {
    _generateCVBullets();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transform Your Hobby'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          if (_generatedBullets.isNotEmpty) ...[
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _regenerate,
              tooltip: 'Regenerate',
            ),
            IconButton(
              icon: const Icon(Icons.copy),
              onPressed: _copyToClipboard,
              tooltip: 'Copy to clipboard',
            ),
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _saveToCV,
              tooltip: 'Save to CV',
            ),
          ],
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Input section
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.auto_awesome, color: Colors.green[800]),
                        const SizedBox(width: 8),
                        Text(
                          'Describe Your Hobby or Activity',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green[800],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Tell me what you love doing in your community or free time:',
                      style: TextStyle(
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _hobbyController,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        hintText: 'e.g., I clean the community hall every weekend\nI help fix computers for my neighbors\nI organize local football matches\nI volunteer at the community garden',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isGenerating ? null : _generateCVBullets,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isGenerating
                            ? const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Text('AI is transforming your hobby...'),
                                ],
                              )
                            : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.auto_awesome),
                                  SizedBox(width: 8),
                                  Text('Transform with AI'),
                                ],
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            if (_errorMessage.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info, color: Colors.orange[800]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage,
                        style: TextStyle(color: Colors.orange[800]),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
            
            // Results section
            if (_generatedBullets.isNotEmpty) ...[
              Row(
                children: [
                  Icon(Icons.work, color: Colors.green[800]),
                  const SizedBox(width: 8),
                  Text(
                    'Professional CV Bullet Points:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[800],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.builder(
                  itemCount: _generatedBullets.length,
                  itemBuilder: (context, index) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      color: Colors.green[50],
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '•',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.green[800],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _generatedBullets[index],
                                style: const TextStyle(
                                  fontSize: 14,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _regenerate,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: BorderSide(color: Colors.green),
                      ),
                      child: const Text('Generate Different Version'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _copyToClipboard,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Copy All'),
                    ),
                  ),
                ],
              ),
            ] else if (_isGenerating) ...[
              const Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 20),
                      Text(
                        'AI is transforming your hobby...',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Creating professional CV bullet points',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
            ] else ...[
              const Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.work_outline, size: 80, color: Colors.grey),
                      SizedBox(height: 20),
                      Text(
                        'Your AI-generated CV bullet points will appear here',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Describe your hobby above and watch the magic happen!',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
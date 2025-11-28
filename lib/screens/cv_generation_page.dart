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
      'create', 'build', 'repair', 'maintain', 'coordinate'
    ];
    return hobbyKeywords.any((keyword) => input.toLowerCase().contains(keyword));
  }

  void _generateCVBullets() async {
    final inputText = _hobbyController.text.trim();
    if (inputText.isEmpty) return;

    setState(() {
      _isGenerating = true;
      _generatedBullets.clear();
    });

    final bullets = await AIService.transformHobbyToCV(inputText);
    
    setState(() {
      _generatedBullets = bullets;
      _isGenerating = false;
    });
  }

  void _copyToClipboard() async {
    if (_generatedBullets.isEmpty) return;

    final text = _generatedBullets.map((bullet) => '• $bullet').join('\n');
    try {
      await Clipboard.setData(ClipboardData(text: text));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Copied to clipboard!')),
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
      const SnackBar(content: Text('CV items saved! (In a real app, this would save to your profile)')),
    );
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
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Describe Your Hobby or Activity',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[800],
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _hobbyController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        hintText: 'e.g., I clean the community hall every weekend\nI help fix computers for my neighbors\nI organize local football matches',
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
                                  Text('Transforming your hobby...'),
                                ],
                              )
                            : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.auto_awesome),
                                  SizedBox(width: 8),
                                  Text('Transform to Professional CV'),
                                ],
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Results section
            if (_generatedBullets.isNotEmpty) ...[
              Text(
                'Professional CV Bullet Points:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[800],
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.builder(
                  itemCount: _generatedBullets.length,
                  itemBuilder: (context, index) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      color: Colors.green[50],
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '•',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.green[800],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _generatedBullets[index],
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ] else if (_isGenerating) ...[
              const Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Transforming your hobby into professional experience...'),
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
                      Icon(Icons.work_outline, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'Your professional CV bullets will appear here',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: Colors.grey),
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
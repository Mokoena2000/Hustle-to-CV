import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hustle to CV',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // ---------------------------------------------------------
  // 🔑 SETUP: Your verified API Key
  // ---------------------------------------------------------
  static const apiKey = 'AIzaSyCyQHrJE95EjqeQp-TepnI7WNGG2ulDHJo'; 

  final TextEditingController _inputController = TextEditingController();
  String _statusMessage = "";
  bool _isLoading = false;

  // 🕵️‍♂️ THE MODEL HUNTER
  // We will try all these names. One of them MUST work.
  final List<String> _modelCandidates = [
    'gemini-1.5-flash',
    'gemini-1.5-flash-latest',
    'gemini-1.5-pro',
    'gemini-pro',
    'gemini-1.0-pro',
  ];

  Future<void> _findWorkingModelAndGenerate() async {
    final informalText = _inputController.text;
    if (informalText.isEmpty) {
      setState(() => _statusMessage = "Please enter some text first.");
      return;
    }

    setState(() {
      _isLoading = true;
      _statusMessage = "🔍 Scanning for working AI models...";
    });

    String? workingModelName;
    GenerateContentResponse? successResponse;

    // --- BRUTE FORCE LOOP ---
    for (String modelName in _modelCandidates) {
      try {
        print("Testing model: $modelName...");
        setState(() => _statusMessage = "Testing: $modelName...");
        
        final model = GenerativeModel(model: modelName, apiKey: apiKey);
        final content = [Content.text("Hello, are you working?")];
        
        // Try a simple handshake
        await model.generateContent(content);
        
        // If we get here, it worked!
        workingModelName = modelName;
        print("✅ SUCCESS! Found working model: $modelName");
        break; // Stop the loop
      } catch (e) {
        print("❌ Failed: $modelName");
      }
    }

    // --- RESULT ---
    if (workingModelName != null) {
      // Now actually generate the CV with the winner
      try {
        setState(() => _statusMessage = "Generating CV using $workingModelName...");
        
        final model = GenerativeModel(model: workingModelName, apiKey: apiKey);
        final prompt = '''
          Act as a professional CV writer for the South African job market. 
          Rewrite this informal text into a professional CV bullet point:
          "$informalText"
        ''';
        
        final response = await model.generateContent([Content.text(prompt)]);
        
        setState(() {
          _statusMessage = "✅ SUCCESS using ($workingModelName):\n\n${response.text}";
        });
      } catch (e) {
        setState(() => _statusMessage = "Error during generation: $e");
      }
    } else {
      setState(() {
        _statusMessage = "❌ FATAL ERROR: No working models found. \n\nCheck if the 'Generative Language API' is enabled in your Google Cloud Console.";
      });
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hustle ➡️ Corporate CV'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
             const Text(
              "Tell us about your hustle:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _inputController,
              maxLines: 4,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'e.g., "I helped my uncle fix taxis..."',
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _findWorkingModelAndGenerate,
              icon: _isLoading 
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) 
                  : const Icon(Icons.search),
              label: Text(_isLoading ? "Scanning Models..." : "Find Model & Generate"),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: SelectableText(
                _statusMessage,
                style: const TextStyle(fontSize: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
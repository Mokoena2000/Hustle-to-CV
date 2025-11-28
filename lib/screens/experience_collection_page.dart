import 'package:flutter/material.dart';
import 'cv_generation_page.dart';
import '../models/cv_data.dart';
import '../utils/local_language.dart';

class ExperienceCollectionPage extends StatefulWidget {
  final String preferredLanguage;

  const ExperienceCollectionPage({
    super.key,
    required this.preferredLanguage,
  });

  @override
  State<ExperienceCollectionPage> createState() => _ExperienceCollectionPageState();
}

class _ExperienceCollectionPageState extends State<ExperienceCollectionPage> {
  final List<String> _experiences = [];
  final TextEditingController _experienceController = TextEditingController();
  final Map<String, List<String>> _commonKasiExperiences = {
  'Sesotho': [
    'Ho hlatsoa litsela le libaka tsa sechaba',
    'Ho lokisa difouno le dikhomphieutha tsa batho',
    'Ho thusa baahi ka mesebetsi ya lapeng',
    'Ho hlopha ditlabelo tsa sechaba',
    'Ho ruta bana ba bancane',
    'Ho rekisa lintho tse nyenyane sechabeng',
    'Ho laola media ea sechaba',
    'Ho hlopha dipapadi tsa bolo',
    'Ho hlokomela serapa sa sechaba',
    'Ho thusa bahloki ka lijo le diaparo',
  ],
  'isiZulu': [
    'Ukususa udoti emgwaqeni',
    'Ukulungisa amaphoyisa kanye namacomputer',
    'Ukusiza omakhelwane ngezinto ezisemakhaya',
    'Ukuhlela imicimbi yomphakathi',
    'Ukufundisa abanye izingane',
    'Ukuthengisa izinto ezincane',
    'Ukuphatha i-social media ye-community',
    'Ukuhlela imidlalo yebhola',
    'Ukuvakashela iziguli nasemakhaya',
    'Ukusiza abampofu ngokudla nangezingubo',
  ],
  'isiXhosa': [
    'Ukususa intlamba ezitalatweni',
    'Ukulungisa iifowuni kunye neekhompyutha',
    'Ukunceda abamelwane ngezinto zasekhaya',
    'Ukulungisa iivenkile zomphakathi',
    'Ukufundisa abanye abantwana',
    'Ukuthengisa izinto ezincinci',
    'Ukuphatha i-social media yoluntu',
    'Ukulungisa imidlalo yebhola',
    'Ukunakekela abagulayo nasezindlini',
    'Ukunceda amahlwempu ngezinto zokutya neempahla',
  ],
  'Afrikaans': [
    'Straat en openbare ruimtes skoonmaak',
    'Fone en rekenaars regmaak vir mense',
    'Bure help met huistake',
    'Gemeenskapsgeleenthede organiseer',
    'Jonger kinders leer',
    'Klein items in die gemeenskap verkoop',
    'Gemeenskap social media bestuur',
    'Sokkertoernooie reël',
    'Gemeenskapstuin onderhou',
    'Behoeftiges help met kos en klere',
  ],
  'Setswana': [
    'Go tlhatlosa ditsela le mafelo a setšhaba',
    'Go baakanya difouno le dikhomphiumara tsa batho',
    'Go thusa baagi ka mesomo ya ntlo',
    'Go rulaganya ditiragatso tsa setšhaba',
    'Go ruta bana ba bannye',
    'Go rekisa dilo tse dinyenyane mo setšhabeng',
    'Go laola media ya setšhaba',
    'Go rulaganya dipapadi tsa bolo',
    'Go hlokomola serapa sa setšhaba',
    'Go thusa ba ba humanegeng ka dijo le diaparo',
  ],
};

  void _addExperience() {
    final experience = _experienceController.text.trim();
    if (experience.isNotEmpty && !_experiences.contains(experience)) {
      setState(() {
        _experiences.add(experience);
        _experienceController.clear();
      });
    }
  }

  void _addCommonExperience(String experience) {
    setState(() {
      if (!_experiences.contains(experience)) {
        _experiences.add(experience);
      }
    });
  }

  void _removeExperience(int index) {
    setState(() {
      _experiences.removeAt(index);
    });
  }

  void _createProfessionalCV() {
    if (_experiences.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(LocalLanguage.getTranslation(
            'Please add at least one experience',
            widget.preferredLanguage,
          )),
        ),
      );
      return;
    }

    final cvData = CVData(
      experiences: List.from(_experiences),
      preferredLanguage: widget.preferredLanguage,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CVGenerationPage(initialInput: _experiences.join('. '),
        ),
      ), 
      
    );
  }

  List<String> _getCommonExperiences() {
    return _commonKasiExperiences[widget.preferredLanguage] ?? 
           _commonKasiExperiences['English']!;
  }

  @override
  Widget build(BuildContext context) {
    final commonExperiences = _getCommonExperiences();

    return Scaffold(
      appBar: AppBar(
        title: Text(LocalLanguage.getTranslation(
          'Add Your Experiences',
          widget.preferredLanguage,
        )),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Instructions
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      LocalLanguage.getTranslation(
                        'Tell us what you do in your community:',
                        widget.preferredLanguage,
                      ),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[800],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      LocalLanguage.getTranslation(
                        'We will turn your Kasi experience into professional skills',
                        widget.preferredLanguage,
                      ),
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Add experience input
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _experienceController,
                    decoration: InputDecoration(
                      hintText: LocalLanguage.getTranslation(
                        'Describe what you do...',
                        widget.preferredLanguage,
                      ),
                      border: const OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _addExperience(),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _addExperience,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                  child: const Icon(Icons.add),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Common experiences
            if (commonExperiences.isNotEmpty) ...[
              Text(
                LocalLanguage.getTranslation(
                  'Common Kasi Experiences:',
                  widget.preferredLanguage,
                ),
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
                children: commonExperiences.map((experience) {
                  return ActionChip(
                    label: Text(experience),
                    onPressed: () => _addCommonExperience(experience),
                    backgroundColor: Colors.green[50],
                    labelStyle: TextStyle(color: Colors.green[800]),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
            ],

            // Added experiences
            Expanded(
              child: _experiences.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.work_outline, size: 64, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          Text(
                            LocalLanguage.getTranslation(
                              'No experiences added yet',
                              widget.preferredLanguage,
                            ),
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: _experiences.length,
                      itemBuilder: (context, index) {
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: Icon(Icons.work, color: Colors.green),
                            title: Text(_experiences[index]),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _removeExperience(index),
                            ),
                          ),
                        );
                      },
                    ),
            ),

            // Create CV button
            if (_experiences.isNotEmpty) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _createProfessionalCV,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    LocalLanguage.getTranslation(
                      'Create Professional CV',
                      widget.preferredLanguage,
                    ),
                    style: const TextStyle(fontSize: 16),
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
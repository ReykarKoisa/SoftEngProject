import 'package:flutter/material.dart';
import 'diagnosis_result_page.dart';

class SicknessSignsPage extends StatefulWidget {
  const SicknessSignsPage({super.key});

  @override
  State<SicknessSignsPage> createState() => _SicknessSignsPageState();
}

class _SicknessSignsPageState extends State<SicknessSignsPage> {
  // The available symptoms for the user to select
  final Map<String, bool> symptoms = {
    'Fever': false,
    'Cough': false,
    'Headache': false,
    'Sore Throat': false,
    'Runny or Stuffy Nose': false,
    'Body Aches or Muscle Pain': false,
    'Fatigue': false,
    'Shortness of Breath': false,
  };

  void generateDiagnosis() {
    final selectedSymptoms = symptoms.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toSet(); // Use a Set for efficient lookups

    if (selectedSymptoms.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one symptom.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    // --- NEW: Scoring-based diagnosis logic ---
    Map<String, int> scores = {
      'Flu': 0,
      'Cold': 0,
      'Strep Throat': 0,
      'Sinus Infection': 0,
      'Bronchitis': 0,
    };

    // Score based on presence of symptoms
    if (selectedSymptoms.contains('Fever')) {
      scores.updateAll((key, value) => value + 1);
    }
    if (selectedSymptoms.contains('Cough')) {
      scores['Flu'] = (scores['Flu'] ?? 0) + 1;
      scores['Cold'] = (scores['Cold'] ?? 0) + 2; // Cough is very common in colds
      scores['Bronchitis'] = (scores['Bronchitis'] ?? 0) + 3; // Key symptom
    }
    if (selectedSymptoms.contains('Headache')) {
      scores['Flu'] = (scores['Flu'] ?? 0) + 1;
      scores['Cold'] = (scores['Cold'] ?? 0) + 1;
      scores['Strep Throat'] = (scores['Strep Throat'] ?? 0) + 1;
      scores['Sinus Infection'] = (scores['Sinus Infection'] ?? 0) + 2;
    }
    if (selectedSymptoms.contains('Sore Throat')) {
      scores['Cold'] = (scores['Cold'] ?? 0) + 2;
      scores['Strep Throat'] = (scores['Strep Throat'] ?? 0) + 3; // Key symptom
      scores['Flu'] = (scores['Flu'] ?? 0) + 1;
    }
    if (selectedSymptoms.contains('Runny or Stuffy Nose')) {
      scores['Cold'] = (scores['Cold'] ?? 0) + 3; // Key symptom
      scores['Sinus Infection'] = (scores['Sinus Infection'] ?? 0) + 2;
    }
    if (selectedSymptoms.contains('Body Aches or Muscle Pain')) {
      scores['Flu'] = (scores['Flu'] ?? 0) + 3; // Key symptom
    }
    if (selectedSymptoms.contains('Fatigue')) {
      scores['Flu'] = (scores['Flu'] ?? 0) + 2;
      scores['Cold'] = (scores['Cold'] ?? 0) + 1;
      scores['Sinus Infection'] = (scores['Sinus Infection'] ?? 0) + 1;
    }
    if (selectedSymptoms.contains('Shortness of Breath')) {
      scores['Bronchitis'] = (scores['Bronchitis'] ?? 0) + 5; // Very strong indicator
    }

    // Apply "Rule-Outs" - makes the logic smarter
    // e.g., A cough makes Strep Throat less likely.
    if (selectedSymptoms.contains('Cough') && selectedSymptoms.contains('Sore Throat')) {
      scores['Strep Throat'] = (scores['Strep Throat'] ?? 0) - 2;
    }
    // Lack of a cough is a strong indicator for Strep.
    if (selectedSymptoms.contains('Sore Throat') && !selectedSymptoms.contains('Cough')) {
      scores['Strep Throat'] = (scores['Strep Throat'] ?? 0) + 2;
    }

    // Determine the highest score
    int maxScore = 0;
    String diagnosis = 'General Symptoms';
    scores.forEach((key, value) {
      if (value > maxScore) {
        maxScore = value;
        diagnosis = key;
      }
    });

    // If the score is too low, it's an unclear pattern
    if (maxScore < 3) {
      diagnosis = 'Unclear Pattern';
    }

    // --- Map diagnosis to final content ---
    String title = 'Diagnosis Result';
    String description = '';
    String tips = '';

    switch (diagnosis) {
      case 'Flu':
        title = 'Potential Flu';
        description = 'The flu is a contagious respiratory illness caused by influenza viruses. Symptoms can be severe and come on suddenly.';
        tips = 'Rest is critical. Stay well-hydrated, take fever-reducers like acetaminophen or ibuprofen, and consult a doctor, as antiviral medication may be prescribed.';
        break;
      case 'Cold':
        title = 'Potential Common Cold';
        description = 'The common cold is a mild viral infection of your nose and throat. It is generally harmless, although it might not feel that way.';
        tips = 'Get plenty of rest, drink warm fluids like tea or soup, and use over-the-counter remedies like decongestants. Symptoms usually resolve in a week or two.';
        break;
      case 'Strep Throat':
        title = 'Potential Strep Throat';
        description = 'Strep throat is a bacterial infection that can make your throat feel sore and scratchy. A key indicator is often the absence of a cough.';
        tips = 'It is important to see a doctor for a strep test, as you may need antibiotics to prevent complications. Gargle with salt water for temporary relief.';
        break;
      case 'Sinus Infection':
        title = 'Potential Sinus Infection';
        description = 'Sinusitis is an inflammation, or swelling, of the tissue lining the sinuses, often causing facial pain and a stuffy nose.';
        tips = 'Use a saline nasal spray, apply a warm compress to your face, and consider using a decongestant. If symptoms persist for over a week, see a doctor.';
        break;
      case 'Bronchitis':
        title = 'Potential Bronchitis / Chest Infection';
        description = 'Given the combination of cough and shortness of breath, this could be bronchitis. This condition affects the airways in your lungs and can be serious.';
        tips = 'Shortness of breath should always be taken seriously. Please consult a healthcare professional promptly for an accurate diagnosis and treatment.';
        break;
      default: // 'Unclear Pattern' or 'General Symptoms'
        title = 'General Symptoms';
        description = 'Your symptoms don\'t point to a specific common illness in our database but still need attention.';
        tips = 'Monitor your symptoms closely. Ensure you get adequate rest and hydration. If symptoms persist or worsen, please consult a healthcare professional.';
        break;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DiagnosisResultPage(
          title: title,
          description: description,
          tips: tips,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sickness Signs'),
        backgroundColor: Colors.deepPurple,
        elevation: 0,
      ),
      backgroundColor: Colors.deepPurple.shade50,
      body: Stack(
        children: [
          Positioned(
            top: -100,
            right: -150,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                color: Colors.deepPurple.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            left: -100,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                color: Colors.purple.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),
                  const Text(
                    'What symptoms are you experiencing?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: ListView(
                      children: symptoms.keys.map((symptom) {
                        return Card(
                          elevation: 2.0,
                          margin: const EdgeInsets.symmetric(vertical: 6.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: CheckboxListTile(
                            title: Text(symptom, style: const TextStyle(fontWeight: FontWeight.w500)),
                            value: symptoms[symptom],
                            activeColor: Colors.deepPurple,
                            controlAffinity: ListTileControlAffinity.leading,
                            onChanged: (bool? value) {
                              setState(() {
                                symptoms[symptom] = value ?? false;
                              });
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.medical_services_outlined),
                    label: const Text('Check Diagnosis', style: TextStyle(fontSize: 18)),
                    onPressed: generateDiagnosis,
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.deepPurple,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      elevation: 5.0,
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

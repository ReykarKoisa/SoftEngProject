import 'package:flutter/material.dart';
import 'diagnosis_result_page.dart';

class SicknessSignsPage extends StatefulWidget {
  const SicknessSignsPage({super.key});

  @override
  State<SicknessSignsPage> createState() => _SicknessSignsPageState();
}

class _SicknessSignsPageState extends State<SicknessSignsPage> {
  final Map<String, bool> symptoms = {
    'Fever': false,
    'Cough': false,
    'Headache': false,
    'Sore Throat': false,
    'Runny Nose': false,
    'Fatigue': false,
    'Muscle Pain': false,
    'Shortness of Breath': false,
  };

  String? diagnosis;

  void generateDiagnosis() {
    final selectedSymptoms = symptoms.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();

    String title;
    String description;
    String tips;

    if (selectedSymptoms.contains('Fever') &&
        selectedSymptoms.contains('Cough') &&
        selectedSymptoms.contains('Fatigue')) {
      title = 'Flu';
      description =
      'The flu is a viral infection that affects your respiratory system.';
      tips =
      'Get plenty of rest, stay hydrated, and take antiviral medication if prescribed.';
    } else if (selectedSymptoms.contains('Headache') &&
        selectedSymptoms.contains('Sore Throat')) {
      title = 'Common Cold';
      description =
      'A mild viral infection of the nose, throat, and sinuses.';
      tips = 'Rest, drink fluids, and use over-the-counter cold remedies.';
    } else if (selectedSymptoms.contains('Shortness of Breath') &&
        selectedSymptoms.contains('Cough')) {
      title = 'Bronchitis';
      description = 'Inflammation of the bronchial tubes in your lungs.';
      tips =
      'Use humidifiers, drink fluids, and possibly use prescribed inhalers.';
    } else if (selectedSymptoms.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one symptom.')),
      );
      return;
    } else {
      title = 'Unknown Illness';
      description = 'Your symptoms do not match a specific known illness.';
      tips = 'Consider consulting a doctor for further diagnosis.';
    }

    setState(() {
      diagnosis = title; // Update state if needed
    });

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
      appBar: AppBar(title: const Text('Sickness Signs')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Select the symptoms you are experiencing:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: symptoms.keys.map((symptom) {
                  return CheckboxListTile(
                    title: Text(symptom),
                    value: symptoms[symptom],
                    onChanged: (bool? value) {
                      setState(() {
                        symptoms[symptom] = value ?? false;
                      });
                    },
                  );
                }).toList(),
              ),
            ),
            ElevatedButton(
              onPressed: generateDiagnosis,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                padding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text('Check Diagnosis'),
            ),
            if (diagnosis != null) ...[
              const SizedBox(height: 20),
              Text(
                diagnosis!,
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

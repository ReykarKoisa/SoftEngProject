// lib/exercise_list.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:intl/intl.dart';

// ------------------- MODELS (Integrated into this file) -------------------

enum ExerciseType { reps, cardio }

class Exercise {
  final String name;
  final String imagePath;
  final ExerciseType type;

  Exercise({
    required this.name,
    required this.imagePath,
    required this.type,
  });
}

class CompletedExercise {
  String name;
  String? sets;
  String? reps;
  String? duration; // in minutes
  String? distance; // in km

  CompletedExercise({
    required this.name,
    this.sets,
    this.reps,
    this.duration,
    this.distance,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'sets': sets,
    'reps': reps,
    'duration': duration,
    'distance': distance,
  };

  factory CompletedExercise.fromJson(Map<String, dynamic> json) {
    return CompletedExercise(
      name: json['name'],
      sets: json['sets'],
      reps: json['reps'],
      duration: json['duration'],
      distance: json['distance'],
    );
  }
}

// ------------------- UI CODE -------------------

class ExerciseListPage extends StatefulWidget {
  ExerciseListPage({super.key});

  final List<Exercise> exercises = [
    Exercise(name: 'Jump Squats', imagePath: 'assets/jump_squats.png', type: ExerciseType.reps),
    Exercise(name: 'Push-Up', imagePath: 'assets/push-up.png', type: ExerciseType.reps),
    Exercise(name: 'Sit-Up', imagePath: 'assets/sit-up.png', type: ExerciseType.reps),
    Exercise(name: 'Running', imagePath: 'assets/running.png', type: ExerciseType.cardio),
    Exercise(name: 'Jump Rope', imagePath: 'assets/jump_rope.png', type: ExerciseType.cardio),
  ];

  @override
  _ExerciseListPageState createState() => _ExerciseListPageState();
}

class _ExerciseListPageState extends State<ExerciseListPage> {
  final Map<String, bool> _selectedExercises = {};
  final Map<String, CompletedExercise> _exerciseData = {};

  @override
  void initState() {
    super.initState();
    for (var exercise in widget.exercises) {
      _selectedExercises[exercise.name] = false;
      _exerciseData[exercise.name] = CompletedExercise(name: exercise.name);
    }
  }

  void _saveExercises() async {
    final prefs = await SharedPreferences.getInstance();
    final List<CompletedExercise> completed = [];

    _selectedExercises.forEach((name, isSelected) {
      if (isSelected) {
        completed.add(_exerciseData[name]!);
      }
    });

    if (completed.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select and fill in at least one exercise.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final List<String> jsonList = completed.map((e) => jsonEncode(e.toJson())).toList();
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    await prefs.setStringList('exercises_$today', jsonList);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Your exercises for today have been saved!'),
        backgroundColor: Colors.green,
      ),
    );
    Navigator.of(context).pop();
  }

  Widget _buildInputFields(Exercise exercise) {
    CompletedExercise data = _exerciseData[exercise.name]!;

    if (exercise.type == ExerciseType.reps) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                onChanged: (value) => data.sets = value,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Sets'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextField(
                onChanged: (value) => data.reps = value,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Reps'),
              ),
            ),
          ],
        ),
      );
    } else { // Cardio
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                onChanged: (value) => data.duration = value,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Duration (min)'),
              ),
            ),
            if (exercise.name == 'Running') ...[
              const SizedBox(width: 16),
              Expanded(
                child: TextField(
                  onChanged: (value) => data.distance = value,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Distance (km)'),
                ),
              ),
            ]
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Today\'s Exercises'),
        backgroundColor: Colors.deepPurple,
      ),
      backgroundColor: Colors.deepPurple.shade50,
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: widget.exercises.length,
              itemBuilder: (context, index) {
                final exercise = widget.exercises[index];
                return Card(
                  elevation: 2.0,
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  child: Column(
                    children: [
                      CheckboxListTile(
                        title: Text(exercise.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        value: _selectedExercises[exercise.name],
                        onChanged: (bool? value) {
                          setState(() {
                            _selectedExercises[exercise.name] = value!;
                          });
                        },
                        secondary: ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Image.asset(
                            exercise.imagePath,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          ),
                        ),
                        activeColor: Colors.deepPurple,
                        controlAffinity: ListTileControlAffinity.leading,
                      ),
                      if (_selectedExercises[exercise.name] == true)
                        _buildInputFields(exercise),
                    ],
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.check),
                label: const Text('Submit'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                onPressed: _saveExercises,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

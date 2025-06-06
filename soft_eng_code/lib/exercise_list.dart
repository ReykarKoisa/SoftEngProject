import 'package:flutter/material.dart';
import 'dart:async';

class Exercise {
  final String name;
  final int duration; // in seconds
  final int sets;
  final String imagePath;

  Exercise({
    required this.name,
    required this.duration,
    required this.sets,
    required this.imagePath,
  });
}

class ExerciseListPage extends StatelessWidget {
  ExerciseListPage({super.key});

  final List<Exercise> exercises = [
    Exercise(name: 'Jump Squats', duration: 90, sets: 3, imagePath: 'assets/jump_squats.png'),
    Exercise(name: 'Jump Rope', duration: 120, sets: 5, imagePath: 'assets/jump_rope.png'),
    Exercise(name: 'Running', duration: 240, sets: 3, imagePath: 'assets/running.png'),
    Exercise(name: 'Sit-Up', duration: 60, sets: 3, imagePath: 'assets/sit-up.png'),
    Exercise(name: 'Push-Up', duration: 60, sets: 3, imagePath: 'assets/push-up.png'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose Your Exercise'),
        backgroundColor: Colors.deepPurple,
      ),
      backgroundColor: Colors.deepPurple.shade50,
      body: Stack(
        children: [
          // Background shapes
          Positioned(
            top: -50,
            left: -100,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.deepPurple.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            right: -120,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                color: Colors.purple.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),
          // Main list content
          ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: exercises.length,
            itemBuilder: (context, index) {
              final exercise = exercises[index];
              return Card(
                elevation: 3.0,
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.asset(
                      exercise.imagePath,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    ),
                  ),
                  title: Text(
                    exercise.name,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  subtitle: Text('${exercise.duration} seconds  •  ${exercise.sets} sets'),
                  trailing: const Icon(Icons.arrow_forward_ios, color: Colors.deepPurple),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TimerPage(exercise: exercise),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class TimerPage extends StatefulWidget {
  final Exercise exercise;

  const TimerPage({super.key, required this.exercise});

  @override
  _TimerPageState createState() => _TimerPageState();
}

class _TimerPageState extends State<TimerPage> {
  late int remainingTime;
  late int totalSets;
  int currentSet = 1;
  Timer? timer;
  bool isRunning = false;

  @override
  void initState() {
    super.initState();
    remainingTime = widget.exercise.duration;
    totalSets = widget.exercise.sets;
  }

  void startTimer() {
    if (currentSet > totalSets) return; // Don't start if all sets are done
    setState(() => isRunning = true);
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (remainingTime > 0) {
        setState(() => remainingTime--);
      } else {
        t.cancel();
        setState(() {
          isRunning = false;
          if (currentSet < totalSets) {
            currentSet++;
            remainingTime = widget.exercise.duration;
          }
        });
      }
    });
  }

  void pauseTimer() {
    timer?.cancel();
    setState(() => isRunning = false);
  }

  String formatTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isFinished = currentSet > totalSets || (currentSet == totalSets && remainingTime == 0);
    double progress = isFinished ? 1.0 : remainingTime / widget.exercise.duration;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.exercise.name),
        backgroundColor: Colors.deepPurple,
        elevation: 0,
      ),
      backgroundColor: Colors.deepPurple.shade50,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Exercise Image
              ClipRRect(
                borderRadius: BorderRadius.circular(16.0),
                child: Image.asset(widget.exercise.imagePath, height: 150, fit: BoxFit.cover),
              ),

              // Radial Timer
              SizedBox(
                width: 250,
                height: 250,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CircularProgressIndicator(
                      value: 1.0 - progress,
                      strokeWidth: 12,
                      backgroundColor: Colors.grey.shade300,
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.deepPurple),
                    ),
                    Center(
                      child: Text(
                        formatTime(remainingTime),
                        style: const TextStyle(fontSize: 64, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),

              // Sets and Controls
              Column(
                children: [
                  Text(
                    isFinished ? 'Workout Complete!' : 'Set $currentSet / $totalSets',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: isFinished ? Colors.green : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (!isFinished)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          onPressed: isRunning ? pauseTimer : startTimer,
                          icon: Icon(isRunning ? Icons.pause : Icons.play_arrow),
                          label: Text(isRunning ? 'Pause' : 'Play'),
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: isRunning ? Colors.orange : Colors.deepPurple,
                            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                            textStyle: const TextStyle(fontSize: 18),
                          ),
                        ),
                      ],
                    ),
                  if (isFinished)
                    ElevatedButton.icon(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.check_circle),
                      label: const Text('Finish'),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        textStyle: const TextStyle(fontSize: 18),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

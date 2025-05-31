import 'package:flutter/material.dart';
import 'dart:async';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Exercise Timer',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'OpenSans',
      ),
      home: ExerciseListPage(),
    );
  }
}

class Exercise {
  final String name;
  final int duration; // in seconds
  final int sets;

  Exercise({required this.name, required this.duration, required this.sets});
}

class ExerciseListPage extends StatelessWidget {
  final List<Exercise> exercises = [
    Exercise(name: 'Jump Squats', duration: 90, sets: 3),
    Exercise(name: 'Jump Rope', duration: 120, sets: 5),
    Exercise(name: 'Running', duration: 240, sets: 3),
    Exercise(name: 'Sit-Up', duration: 60, sets: 3),
    Exercise(name: 'Push-Up', duration: 60, sets: 3),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Exercises',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 26, // slightly bigger than the default (~20)
          ),
        ),
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: exercises.length,
        itemBuilder: (context, index) {
          final exercise = exercises[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TimerPage(exercise: exercise),
                ),
              );
            },
            child: Container(
              height: 120,
              margin: EdgeInsets.only(bottom: 16),
              padding: EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.blue[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(
                            'assets/${exercise.name.toLowerCase().replaceAll(' ', '_')}.png'),
                        fit: BoxFit.cover,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(exercise.name,
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold)),
                        Text('${exercise.duration} seconds',
                            style: TextStyle(fontSize: 16)),
                        Text('${exercise.sets} sets',
                            style: TextStyle(fontSize: 16)),
                      ],
                    ),
                  ),
                  Icon(Icons.play_circle_fill,
                      size: 40, color: Colors.blueAccent),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class TimerPage extends StatefulWidget {
  final Exercise exercise;

  TimerPage({required this.exercise});

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
    if (currentSet > totalSets) return;
    setState(() => isRunning = true);
    timer = Timer.periodic(Duration(seconds: 1), (t) {
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
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.exercise.name,
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
      ),
      body: Stack(
        children: [
          // ☑ Enlarged circle: now 200% of previous (was w*1.5 × h*0.4, now w*3 × h*0.8)
          Positioned(
            bottom: -h * 0.4,
            left: -w * 0.25,
            right: -w * 0.25, // adjusted from -w * 0.75
            child: Container(
              width: w * 4,
              height: h * 0.85,
              decoration: BoxDecoration(
                color: Colors.blue[50],
                shape: BoxShape.circle,
              ),
            ),
          ),

          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                Text(widget.exercise.name,
                    style:
                        TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                SizedBox(height: 16),

                // Exercise Card
                Container(
                  height: 120,
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.blue[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage(
                                'assets/${widget.exercise.name.toLowerCase().replaceAll(' ', '_')}.png'),
                            fit: BoxFit.cover,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(widget.exercise.name,
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold)),
                            Text('${widget.exercise.duration} seconds',
                                style: TextStyle(fontSize: 16)),
                            Text('${widget.exercise.sets} sets',
                                style: TextStyle(fontSize: 16)),
                          ],
                        ),
                      ),
                      Icon(Icons.play_circle_fill,
                          size: 40, color: Colors.blueAccent),
                    ],
                  ),
                ),

                SizedBox(height: 24),
                Text('Progress',
                    style:
                        TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                SizedBox(height: 16),
                Text(formatTime(remainingTime),
                    style:
                        TextStyle(fontSize: 48, fontWeight: FontWeight.bold)),
                SizedBox(height: 16),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: isRunning ? null : startTimer,
                      icon: Icon(Icons.play_arrow),
                      label: Text('Play'),
                    ),
                    SizedBox(width: 16),
                    ElevatedButton.icon(
                      onPressed: isRunning ? pauseTimer : null,
                      icon: Icon(Icons.pause),
                      label: Text('Pause'),
                    ),
                  ],
                ),

                SizedBox(height: 16),
                Text('Set $currentSet / $totalSets',
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                if (currentSet > totalSets)
                  Text('Finished',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

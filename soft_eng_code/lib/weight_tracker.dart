// lib/weight_tracker.dart

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:math';
import 'package:intl/intl.dart';
import 'package:soft_eng_code/exercise_list.dart'; // Import exercise_list.dart to get model access

class WeightTracker extends StatefulWidget {
  const WeightTracker({super.key});

  @override
  _WeightTrackerState createState() => _WeightTrackerState();
}

class _WeightTrackerState extends State<WeightTracker> {
  List<WeightEntry> weightEntries = [];
  double targetWeight = 70;

  double get currentWeight => weightEntries.isNotEmpty ? weightEntries.last.weight : 0;
  double get startingWeight => weightEntries.isNotEmpty ? weightEntries.first.weight : 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final storedWeightsJSON = prefs.getStringList('weight_entries_v2') ?? [];
    List<WeightEntry> loadedEntries = [];

    for (String jsonEntry in storedWeightsJSON) {
      final entryMap = jsonDecode(jsonEntry);
      final entry = WeightEntry.fromJson(entryMap);

      final dateKey = DateFormat('yyyy-MM-dd').format(entry.date);
      final exercisesJson = prefs.getStringList('exercises_$dateKey') ?? [];

      if (exercisesJson.isNotEmpty) {
        entry.exercises = exercisesJson
            .map((json) => CompletedExercise.fromJson(jsonDecode(json)))
            .toList();
      }
      loadedEntries.add(entry);
    }

    setState(() {
      weightEntries = loadedEntries;
      targetWeight = prefs.getDouble('targetWeight') ?? 70;
    });
  }

  String _formatExercise(CompletedExercise ex) {
    List<String> details = [];
    if (ex.sets != null && ex.sets!.isNotEmpty) details.add('${ex.sets} sets');
    if (ex.reps != null && ex.reps!.isNotEmpty) details.add('${ex.reps} reps');
    if (ex.duration != null && ex.duration!.isNotEmpty) details.add('${ex.duration} min');
    if (ex.distance != null && ex.distance!.isNotEmpty) details.add('${ex.distance} km');

    return '${ex.name}: ${details.join(" / ")}';
  }

  // ... (The rest of the _WeightTrackerState class is unchanged)
  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    final weightListJSON = weightEntries.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList('weight_entries_v2', weightListJSON);
    await prefs.setDouble('targetWeight', targetWeight);
  }

  void _addCurrentWeight(double newWeight) async {
    final today = DateTime.now();
    final todayDateOnly = DateTime(today.year, today.month, today.day);

    setState(() {
      // Check if there is already an entry for today and update it
      final todayEntryIndex = weightEntries.indexWhere((entry) =>
      entry.date.year == todayDateOnly.year &&
          entry.date.month == todayDateOnly.month &&
          entry.date.day == todayDateOnly.day);

      if (todayEntryIndex != -1) {
        weightEntries[todayEntryIndex].weight = newWeight;
      } else {
        weightEntries.add(WeightEntry(date: todayDateOnly, weight: newWeight));
      }
      // Keep the list sorted by date
      weightEntries.sort((a, b) => a.date.compareTo(b.date));
    });
    await _saveData();
    await _loadData(); // Reload to fetch associated exercises
  }

  Future<void> _clearData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear History?'),
        content: const Text('This will delete all your weight and exercise entries. This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.remove('weight_entries_v2');
              // Also clear exercise data
              final keys = prefs.getKeys();
              for (String key in keys) {
                if (key.startsWith('exercises_')) {
                  await prefs.remove(key);
                }
              }
              Navigator.of(context).pop(true);
            },
            child: const Text('Clear', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed ?? false) {
      setState(() => weightEntries = []);
    }
  }

  void _changeTargetWeight(double newTarget) {
    setState(() => targetWeight = newTarget);
    _saveData();
  }

  void _showInputDialog(String title, Function(double) onSubmit) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(hintText: "Enter weight in kg"),
        ),
        actions: [
          TextButton(
            onPressed: () {
              final value = double.tryParse(controller.text);
              Navigator.of(dialogContext).pop();
              if (value != null) onSubmit(value);
            },
            child: const Text("Submit"),
          ),
        ],
      ),
    );
  }

  Widget _buildChart() {
    if (weightEntries.length < 2) {
      return Center(
        child: Text(
          "Add at least two weight entries to see your progress chart!",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey[600], fontSize: 16),
        ),
      );
    }

    final spots = weightEntries
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value.weight))
        .toList();
    final minY = weightEntries.map((e) => e.weight).reduce(min) - 2;
    final maxY = weightEntries.map((e) => e.weight).reduce(max) + 2;

    return LineChart(
      LineChartData(
        minY: minY,
        maxY: maxY,
        backgroundColor: Colors.deepPurple.withOpacity(0.05),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) {
            return const FlLine(color: Colors.deepPurple, strokeWidth: 1, dashArray: [8, 4]);
          },
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40)),
          bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 32,
                  interval: 1,
                  getTitlesWidget: (value, meta) {
                    final index = value.toInt();
                    if (index >= 0 && index < weightEntries.length) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(DateFormat('d MMM').format(weightEntries[index].date)),
                      );
                    }
                    return const Text('');
                  })),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            tooltipBgColor: Colors.deepPurple,
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                final entry = weightEntries[spot.spotIndex];
                return LineTooltipItem(
                  '${entry.weight.toStringAsFixed(1)} kg\n',
                  const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  children: [
                    TextSpan(
                      text: DateFormat('MMM d,快樂').format(entry.date),
                      style: TextStyle(color: Colors.white.withOpacity(0.8)),
                    ),
                  ],
                );
              }).toList();
            },
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            isCurved: true,
            spots: spots,
            barWidth: 4,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            gradient: const LinearGradient(colors: [Colors.purpleAccent, Colors.deepPurple]),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [Colors.purpleAccent.withOpacity(0.3), Colors.deepPurple.withOpacity(0.0)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Weight Tracker'),
          bottom: const TabBar(tabs: [Tab(text: 'Overview'), Tab(text: 'History')]),
        ),
        body: TabBarView(
          children: [
            // Overview Tab
            SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 250, child: _buildChart()),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ElevatedButton.icon(
                          icon: const Icon(Icons.add),
                          label: const Text("Add Weight"),
                          onPressed: () => _showInputDialog("Add Today's Weight", _addCurrentWeight),
                        ),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.flag),
                          label: const Text("Set Target"),
                          onPressed: () => _showInputDialog("Change Target Weight", _changeTargetWeight),
                        ),
                        TextButton.icon(
                          icon: const Icon(Icons.delete_sweep, color: Colors.redAccent),
                          label: const Text("Clear", style: TextStyle(color: Colors.redAccent)),
                          onPressed: _clearData,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // History Tab
            ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: weightEntries.length,
              itemBuilder: (context, index) {
                final entry = weightEntries.reversed.toList()[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              DateFormat('EEEE, MMM d, yyyy').format(entry.date),
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            Text(
                              "${entry.weight.toStringAsFixed(1)} kg",
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.deepPurple),
                            ),
                          ],
                        ),
                        const Divider(height: 20),
                        if (entry.exercises.isNotEmpty) ...[
                          const Text("Completed Exercises:", style: TextStyle(fontWeight: FontWeight.w600)),
                          const SizedBox(height: 8),
                          ...entry.exercises.map((ex) => Padding(
                            padding: const EdgeInsets.only(bottom: 4.0),
                            child: Text("• ${_formatExercise(ex)}"),
                          ))
                        ] else ...[
                          Text(
                            "No exercises recorded for this day.",
                            style: TextStyle(color: Colors.grey.shade600, fontStyle: FontStyle.italic),
                          )
                        ]
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class WeightEntry {
  DateTime date;
  double weight;
  List<CompletedExercise> exercises;

  WeightEntry({required this.date, required this.weight, this.exercises = const []});

  Map<String, dynamic> toJson() => {
    'date': date.toIso8601String(),
    'weight': weight,
  };

  factory WeightEntry.fromJson(Map<String, dynamic> json) => WeightEntry(
    date: DateTime.parse(json['date']),
    weight: json['weight'],
  );
}
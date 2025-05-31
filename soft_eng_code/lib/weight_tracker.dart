import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class WeightTracker extends StatefulWidget {
  const WeightTracker({super.key});

  @override
  _WeightTrackerState createState() => _WeightTrackerState();
}

class _WeightTrackerState extends State<WeightTracker> {
  List<WeightEntry> weightEntries = [
    WeightEntry(day: 1, weight: 80),
    WeightEntry(day: 2, weight: 79),
    WeightEntry(day: 3, weight: 78.5),
    WeightEntry(day: 4, weight: 77.8),
    WeightEntry(day: 5, weight: 77),
  ];

  double get currentWeight => weightEntries.last.weight;
  double targetWeight = 70;

  void _addCurrentWeight(double newWeight) {
    setState(() {
      weightEntries.add(WeightEntry(day: weightEntries.length + 1, weight: newWeight));
    });
  }

  void _changeTargetWeight(double newTarget) {
    setState(() {
      targetWeight = newTarget;
    });
  }

  void _showInputDialog(String title, Function(double) onSubmit) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(hintText: "Enter weight in kg"),
        ),
        actions: [
          TextButton(
            onPressed: () {
              final value = double.tryParse(controller.text);
              if (value != null) onSubmit(value);
              Navigator.pop(context);
            },
            child: Text("Submit"),
          ),
        ],
      ),
    );
  }

  Widget _buildChart() {
    List<FlSpot> spots = weightEntries
        .map((e) => FlSpot(e.day.toDouble(), e.weight))
        .toList();

    return LineChart(
      LineChartData(
        minX: 1,
        maxX: weightEntries.length.toDouble(),
        minY: weightEntries.map((e) => e.weight).reduce((a, b) => a < b ? a : b) - 1,
        maxY: weightEntries.map((e) => e.weight).reduce((a, b) => a > b ? a : b) + 1,
        gridData: FlGridData(show: false),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true, reservedSize: 32),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true, reservedSize: 28),
          ),
          rightTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(show: true),
        lineBarsData: [
          LineChartBarData(
            isCurved: true,
            spots: spots,
            barWidth: 3,
            isStrokeCapRound: true,
            gradient: LinearGradient(colors: [Colors.deepPurple, Colors.purpleAccent]),
            dotData: FlDotData(show: true),
            belowBarData: BarAreaData(show: false),
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
          title: Text('Weight Tracker'),
          bottom: TabBar(
            tabs: [
              Tab(text: 'Overview'),
              Tab(text: 'History'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 200, child: _buildChart()),
                  SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        colors: [Colors.deepPurple, Colors.purpleAccent],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Your Progress",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Current", style: TextStyle(color: Colors.white70)),
                                Text(
                                  "${currentWeight.toStringAsFixed(1)} kg",
                                  style: TextStyle(color: Colors.white, fontSize: 18),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text("Target", style: TextStyle(color: Colors.white70)),
                                Text(
                                  "${targetWeight.toStringAsFixed(1)} kg",
                                  style: TextStyle(color: Colors.white, fontSize: 18),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            minHeight: 10,
                            value: ((weightEntries.first.weight - currentWeight) /
                                (weightEntries.first.weight - targetWeight))
                                .clamp(0.0, 1.0),
                            backgroundColor: Colors.white24,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: weightEntries.length,
              itemBuilder: (context, index) {
                final entry = weightEntries[index];
                return ListTile(
                  title: Text("Day ${entry.day}"),
                  trailing: Text("${entry.weight.toStringAsFixed(1)} kg"),
                );
              },
            ),
          ],
        ),
        bottomNavigationBar: BottomAppBar(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: () => _showInputDialog("Add Current Weight", _addCurrentWeight),
                  child: Text("Add Weight"),
                ),
                ElevatedButton(
                  onPressed: () => _showInputDialog("Change Target Weight", _changeTargetWeight),
                  child: Text("Change Target"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class WeightEntry {
  final int day;
  final double weight;

  WeightEntry({required this.day, required this.weight});
}
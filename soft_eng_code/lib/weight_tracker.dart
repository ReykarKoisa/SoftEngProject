import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';

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
    final storedWeights = prefs.getStringList('weights') ?? [];
    setState(() {
      weightEntries = storedWeights.map((s) {
        final parts = s.split(',');
        return WeightEntry(day: int.parse(parts[0]), weight: double.parse(parts[1]));
      }).toList();
      targetWeight = prefs.getDouble('targetWeight') ?? 70;
    });
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    final weightList = weightEntries.map((e) => '${e.day},${e.weight}').toList();
    await prefs.setStringList('weights', weightList);
    await prefs.setDouble('targetWeight', targetWeight);
  }

  Future<void> _clearData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear History?'),
        content: const Text('This will delete all your weight entries. This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Clear', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed ?? false) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('weights');
      setState(() => weightEntries = []);
    }
  }


  void _showRecommendationDialog({required String title, required String content}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text("OK")),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.pushNamed(context, '/exercises');
            },
            child: const Text("View Exercises"),
          ),
        ],
      ),
    );
  }

  void _addCurrentWeight(double newWeight) {
    if (weightEntries.isNotEmpty && newWeight == weightEntries.last.weight) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Weight is the same as last entry. Not stored."), duration: Duration(seconds: 2)),
      );
      return;
    }

    final double? previousWeight = weightEntries.isNotEmpty ? weightEntries.last.weight : null;

    setState(() {
      weightEntries.add(WeightEntry(day: (weightEntries.lastOrNull?.day ?? 0) + 1, weight: newWeight));
    });
    _saveData();

    if (previousWeight != null) {
      double weightChange = newWeight - previousWeight;

      // CHANGE: Updated the threshold to > 2kg for gain
      if (weightChange > 2) {
        _showRecommendationDialog(
          title: "Significant Weight Gain Recorded",
          content: "A sudden weight gain of over 2kg has been noted. While fluctuations are normal, it's wise to be mindful. Regular activity can help. If this trend continues, consider consulting a healthcare professional.",
        );
      }
      // CHANGE: Updated the threshold to > 2kg for loss
      else if (weightChange < -2) {
        _showRecommendationDialog(
          title: "Significant Weight Loss Recorded",
          content: "A rapid weight loss of over 2kg has been noted. Please ensure you are nourishing your body adequately. For health and sustainable results, a slower pace is often recommended. Consider consulting a healthcare professional.",
        );
      }
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
    if (weightEntries.isEmpty) {
      return Center(
        child: Text("Add a weight entry to see your progress!", style: TextStyle(color: Colors.grey[600])),
      );
    }

    final spots = weightEntries.map((e) => FlSpot(e.day.toDouble(), e.weight)).toList();
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
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) => Text(
                value.toStringAsFixed(0),
                style: const TextStyle(color: Colors.black, fontSize: 12),
                textAlign: TextAlign.left,
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 32,
              interval: 1,
              getTitlesWidget: (value, meta) => Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text('D${value.toInt()}', style: const TextStyle(fontSize: 12)),
              ),
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            tooltipBgColor: Colors.deepPurple,
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                return LineTooltipItem(
                  '${spot.y.toStringAsFixed(1)} kg\n',
                  const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  children: [
                    TextSpan(
                      text: 'Day ${spot.x.toInt()}',
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
    double progressValue = 0.0;
    if (weightEntries.isNotEmpty && startingWeight != targetWeight) {
      progressValue = ((startingWeight - currentWeight) / (startingWeight - targetWeight)).clamp(0.0, 1.0);
    }

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Weight Tracker'),
          bottom: const TabBar(tabs: [Tab(text: 'Overview'), Tab(text: 'History')]),
        ),
        body: TabBarView(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 250, child: _buildChart()),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: const LinearGradient(
                        colors: [Colors.deepPurple, Colors.purpleAccent],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4))],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Your Progress", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Current", style: TextStyle(color: Colors.white70)),
                                Text("${currentWeight.toStringAsFixed(1)} kg", style: const TextStyle(color: Colors.white, fontSize: 18)),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Text("Target", style: TextStyle(color: Colors.white70)),
                                Text("${targetWeight.toStringAsFixed(1)} kg", style: const TextStyle(color: Colors.white, fontSize: 18)),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            minHeight: 10,
                            value: progressValue,
                            backgroundColor: Colors.white24,
                            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ElevatedButton.icon(
                          icon: const Icon(Icons.add),
                          label: const Text("Add Weight"),
                          onPressed: () => _showInputDialog("Add Current Weight", _addCurrentWeight),
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
            ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: weightEntries.length,
              itemBuilder: (context, index) {
                final entry = weightEntries.reversed.toList()[index];
                return ListTile(
                  title: Text("Day ${entry.day}"),
                  trailing: Text("${entry.weight.toStringAsFixed(1)} kg"),
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
  final int day;
  final double weight;
  WeightEntry({required this.day, required this.weight});
}
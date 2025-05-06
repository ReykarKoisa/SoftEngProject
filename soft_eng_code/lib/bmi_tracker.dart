// lib/main.dart
import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(const BMICalculatorApp());
}

class BMICalculatorApp extends StatelessWidget {
  const BMICalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BMI Calculator',
      theme: ThemeData(
        primarySwatch: Colors.purple, // comment: change to your brand color
        scaffoldBackgroundColor: Colors.grey[200],
      ),
      home: const InputPage(),
    );
  }
}

enum Gender { male, female }

class InputPage extends StatefulWidget {
  const InputPage({super.key});

  @override
  State<InputPage> createState() => _InputPageState();
}

class _InputPageState extends State<InputPage> {
  Gender? selectedGender;
  double height = 174;
  int weight = 67;
  int age = 30;

  @override
  Widget build(BuildContext context) {
    const cardColor = Colors.white;
    const activeColor = Colors.purple; // comment: swap out for your purple
    const inactiveColor = Colors.white;

    return Scaffold(
      appBar: AppBar(title: const Text('BMI Calculator')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            // Gender selector row
            Row(
              children: [
                Expanded(child: _GenderCard(
                  label: 'Male',
                  icon: Icons.male, // placeholder icon: swap out if you have asset
                  isSelected: selectedGender == Gender.male,
                  onTap: () => setState(() => selectedGender = Gender.male),
                )),
                const SizedBox(width: 12),
                Expanded(child: _GenderCard(
                  label: 'Female',
                  icon: Icons.female, // placeholder icon: swap out if you have asset
                  isSelected: selectedGender == Gender.female,
                  onTap: () => setState(() => selectedGender = Gender.female),
                )),
              ],
            ),
            const SizedBox(height: 12),
            // Height slider card
            Card(
              color: cardColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Column(
                  children: [
                    const Text('Height', style: TextStyle(fontSize: 18)),
                    const SizedBox(height: 8),
                    Text('${height.round()} cm', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    Slider(
                      value: height,
                      min: 100,
                      max: 220,
                      activeColor: activeColor,
                      onChanged: (v) => setState(() => height = v),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Age & Weight row
            Row(
              children: [
                Expanded(child: _CounterCard(
                  label: 'Age',
                  value: age,
                  onIncrement: () => setState(() => age++),
                  onDecrement: () => setState(() => age--),
                )),
                const SizedBox(width: 12),
                Expanded(child: _CounterCard(
                  label: 'Weight (kg)',
                  value: weight,
                  onIncrement: () => setState(() => weight++),
                  onDecrement: () => setState(() => weight--),
                )),
              ],
            ),
            const Spacer(),
            // Calculate button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.calculate),
                label: const Text('Calculate', style: TextStyle(fontSize: 18)),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                ),
                onPressed: () {
                  final bmi = weight / pow(height / 100, 2);
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => ResultPage(bmi: bmi)),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GenderCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  const _GenderCard({
    required this.label, required this.icon,
    required this.isSelected, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? Colors.purple[100]! : Colors.white;
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: Colors.grey[700]), // comment: replace with Image.asset if needed
              const SizedBox(height: 8),
              Text(label),
            ],
          ),
        ),
      ),
    );
  }
}

class _CounterCard extends StatelessWidget {
  final String label;
  final int value;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  const _CounterCard({
    required this.label,
    required this.value,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          children: [
            Text(label, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text('$value', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _RoundIconButton(icon: Icons.remove, onPressed: onDecrement),
                const SizedBox(width: 16),
                _RoundIconButton(icon: Icons.add, onPressed: onIncrement),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  const _RoundIconButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return RawMaterialButton(
      onPressed: onPressed,
      shape: const CircleBorder(),
      fillColor: Colors.grey[200],
      constraints: const BoxConstraints.tightFor(width: 36, height: 36),
      child: Icon(icon),
    );
  }
}

class ResultPage extends StatelessWidget {
  final double bmi;
  const ResultPage({required this.bmi, super.key});

  String get category {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25) return 'Healthy';
    if (bmi < 30) return 'Overweight';
    if (bmi < 40) return 'Obese';
    return 'Severely Obese';
  }

  String get message {
    if (bmi < 18.5) return 'You are underweight.';
    if (bmi < 25) return 'You are fit and healthy!';
    if (bmi < 30) return 'You are overweight.';
    if (bmi < 40) return 'You are obese.';
    return 'You are severely obese.';
  }

  @override
  Widget build(BuildContext context) {
    const gaugeBg = Colors.grey;
    const gaugePointer = Colors.purple; // change to your theme color

    return Scaffold(
      appBar: AppBar(title: const Text('Your BMI')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 12),
          child: Column(
            children: [
              // Gauge
              SizedBox(
                width: 200,
                height: 120,
                child: CustomPaint(
                  painter: _GaugePainter(bmi: bmi, bgColor: gaugeBg, pointerColor: gaugePointer),
                ),
              ),
              const SizedBox(height: 16),
              Text(bmi.toStringAsFixed(1), style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(category, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text(message, textAlign: TextAlign.center),
              const Spacer(),
              // Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Re-Calculate'),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
                    child: const Text('Home'),
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

class _GaugePainter extends CustomPainter {
  final double bmi;
  final Color bgColor;
  final Color pointerColor;

  _GaugePainter({required this.bmi, required this.bgColor, required this.pointerColor});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width/2, size.height);
    final radius = size.width/2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final bgPaint = Paint()
      ..color = bgColor.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16;

    canvas.drawArc(rect, pi, pi, false, bgPaint);

    // pointer sweep
    final maxBMI = 50.0;
    final sweep = (bmi.clamp(0, maxBMI) / maxBMI) * pi;
    final pointerPaint = Paint()
      ..color = pointerColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, pi, sweep, false, pointerPaint);
  }

  @override
  bool shouldRepaint(covariant _GaugePainter old) => old.bmi != bmi;
}


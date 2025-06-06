import 'dart:math';
import 'package:flutter/material.dart';

// Main app entry point (can be removed if bmi_tracker is not run standalone)
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
        primarySwatch: Colors.deepPurple,
        scaffoldBackgroundColor: Colors.deepPurple.shade50,
        fontFamily: 'sans-serif',
      ),
      home: const InputPage(),
    );
  }
}

// Enum to hold the state for gender selection
enum Gender { male, female }

// Main input page UI
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

  /// Shows a dialog to manually input a numeric value.
  void _showManualInputDialog({
    required String title,
    required String initialValue,
    required Function(String) onSubmitted,
  }) {
    final controller = TextEditingController(text: initialValue);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Enter $title'),
          content: TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            autofocus: true,
            decoration: InputDecoration(
              hintText: title,
              suffixText: title == 'Height' ? 'cm' : (title == 'Weight' ? 'kg' : ''),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                onSubmitted(controller.text);
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BMI Calculator'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: Stack(
        children: [
          // Background decorative shapes
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                color: Colors.deepPurple.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -120,
            right: -150,
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                color: Colors.purple.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),
          // Main scrollable content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Gender', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _GenderCard(
                          label: 'Male',
                          icon: Icons.male,
                          isSelected: selectedGender == Gender.male,
                          onTap: () => setState(() => selectedGender = Gender.male),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _GenderCard(
                          label: 'Female',
                          icon: Icons.female,
                          isSelected: selectedGender == Gender.female,
                          onTap: () => setState(() => selectedGender = Gender.female),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Height Card
                  _buildTappableCard(
                    title: 'Height',
                    value: '${height.round()} cm',
                    onTap: () => _showManualInputDialog(
                      title: 'Height',
                      initialValue: height.round().toString(),
                      onSubmitted: (val) => setState(() => height = double.tryParse(val) ?? height),
                    ),
                    child: Slider(
                      value: height,
                      min: 100,
                      max: 220,
                      activeColor: Colors.deepPurple,
                      inactiveColor: Colors.deepPurple.shade100,
                      onChanged: (v) => setState(() => height = v),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Weight & Age Row
                  Row(
                    children: [
                      Expanded(
                        child: _buildTappableCard(
                          title: 'Weight',
                          value: '$weight kg',
                          onTap: () => _showManualInputDialog(
                            title: 'Weight',
                            initialValue: weight.toString(),
                            onSubmitted: (val) => setState(() => weight = int.tryParse(val) ?? weight),
                          ),
                          child: _CounterControls(
                            onIncrement: () => setState(() => weight++),
                            onDecrement: () => setState(() => weight--),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildTappableCard(
                          title: 'Age',
                          value: '$age',
                          onTap: () => _showManualInputDialog(
                            title: 'Age',
                            initialValue: age.toString(),
                            onSubmitted: (val) => setState(() => age = int.tryParse(val) ?? age),
                          ),
                          child: _CounterControls(
                            onIncrement: () => setState(() => age++),
                            onDecrement: () => setState(() => age--),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Calculate Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.calculate_outlined),
                      label: const Text('Calculate BMI'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      onPressed: () {
                        if (selectedGender == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Please select a gender.'), backgroundColor: Colors.redAccent)
                          );
                          return;
                        }
                        final bmi = weight / pow(height / 100, 2);
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => ResultPage(bmi: bmi)),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Helper widget to build the main interactive cards.
  Widget _buildTappableCard({
    required String title,
    required String value,
    required VoidCallback onTap,
    required Widget child,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(title, style: TextStyle(fontSize: 16, color: Colors.grey.shade600)),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: onTap,
              child: Text(value, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 8),
            child,
          ],
        ),
      ),
    );
  }
}

/// A card for selecting gender.
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
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: isSelected ? Colors.deepPurple.shade100 : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Colors.deepPurple : Colors.grey.shade300,
            width: 2,
          ),
          boxShadow: isSelected ? [
            BoxShadow(color: Colors.deepPurple.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))
          ] : [],
        ),
        child: Column(
          children: [
            Icon(icon, size: 48, color: isSelected ? Colors.deepPurple : Colors.grey.shade700),
            const SizedBox(height: 8),
            Text(label, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
          ],
        ),
      ),
    );
  }
}

/// The +/- buttons for the counter cards.
class _CounterControls extends StatelessWidget {
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  const _CounterControls({required this.onIncrement, required this.onDecrement});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _RoundIconButton(icon: Icons.remove, onPressed: onDecrement),
        const SizedBox(width: 24),
        _RoundIconButton(icon: Icons.add, onPressed: onIncrement),
      ],
    );
  }
}

/// A stylized round icon button.
class _RoundIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  const _RoundIconButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return RawMaterialButton(
      onPressed: onPressed,
      elevation: 2.0,
      fillColor: Colors.deepPurple.shade50,
      constraints: const BoxConstraints.tightFor(width: 48, height: 48),
      shape: const CircleBorder(),
      child: Icon(icon, color: Colors.deepPurple),
    );
  }
}

// Result page UI
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

  Color get categoryColor {
    if (bmi < 18.5) return Colors.blue;
    if (bmi < 25) return Colors.green;
    if (bmi < 30) return Colors.orange;
    return Colors.red;
  }

  String get message {
    if (bmi < 18.5) return 'You are in the underweight range. Consider speaking with a nutritionist to ensure you are getting enough nutrients.';
    if (bmi < 25) return 'Great job! Your BMI is in the healthy range. Keep up the balanced lifestyle!';
    if (bmi < 30) return 'You are in the overweight range. A balanced diet and regular exercise can help you reach a healthier weight.';
    return 'Your BMI is in the obese range. It is recommended to consult with a healthcare professional to create a safe and effective health plan.';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Result'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              SizedBox(
                width: 250,
                height: 250,
                child: CustomPaint(
                  painter: _GaugePainter(bmi: bmi, categoryColor: categoryColor),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Your BMI', style: TextStyle(fontSize: 16, color: Colors.grey)),
                        Text(bmi.toStringAsFixed(1), style: const TextStyle(fontSize: 56, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                category,
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: categoryColor),
              ),
              const SizedBox(height: 12),
              Text(message, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, height: 1.5)),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  child: const Text('Re-Calculate'),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

/// A custom painter for the beautiful radial BMI gauge.
class _GaugePainter extends CustomPainter {
  final double bmi;
  final Color categoryColor;

  _GaugePainter({required this.bmi, required this.categoryColor});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    const strokeWidth = 20.0;
    const totalAngle = 1.5 * pi; // 270 degrees
    const startAngle = -1.25 * pi; // Start from bottom-left

    // Background Arc
    final bgPaint = Paint()
      ..color = Colors.grey.shade300
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), startAngle, totalAngle, false, bgPaint);

    // Value Arc
    final maxBmiForGauge = 40.0;
    final sweepAngle = (bmi.clamp(0, maxBmiForGauge) / maxBmiForGauge) * totalAngle;
    final valuePaint = Paint()
      ..color = categoryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), startAngle, sweepAngle, false, valuePaint);
  }

  @override
  bool shouldRepaint(covariant _GaugePainter old) => old.bmi != bmi;
}

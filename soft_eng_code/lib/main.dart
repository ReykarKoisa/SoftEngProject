// lib/main.dart
import 'package:flutter/material.dart';
import 'package:soft_eng_code/bmi_tracker.dart';
import 'package:soft_eng_code/recipe_list_screen.dart';
import 'package:soft_eng_code/weight_tracker.dart';
import 'package:soft_eng_code/exercise_list.dart'; // ← Add this line
import 'package:soft_eng_code/sickness_signs.dart';

void main() => runApp(const FitnessApp());

class FitnessApp extends StatelessWidget {
  const FitnessApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fitness App',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        scaffoldBackgroundColor: Colors.grey[100],
        textTheme: const TextTheme(
          bodyMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (c) => const WelcomePage(),
        '/home': (c) => const HomePage(),
        '/bmi': (c) => const InputPage(),
        '/weight': (c) => const WeightTracker(),
        '/exercises': (c) => ExerciseListPage(), // ← Replace this line
        '/recipes': (c) => const RecipeListScreen(),
        '/health': (c) => const SicknessSignsPage(),
      },
    );
  }
}

// ─── Curved Welcome Page (UPDATED with Animation and Styling) ──────────────────

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          ClipPath(
            clipper: _BottomWaveClipper(),
            child: Container(
              height: MediaQuery.of(context).size.height * 0.4,
              color: Colors.deepPurple,
              // You can add an image here if you like
              // child: Image.asset('assets/your_welcome_image.png', fit: BoxFit.cover),
            ),
          ),
          const SizedBox(height: 48),
          FadeTransition(
            opacity: _fadeAnimation,
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Hey User! Ready to\nlevel up your health?',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, height: 1.3),
              ),
            ),
          ),
          const Spacer(),
          FadeTransition(
            opacity: _fadeAnimation,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white, // CHANGE: Ensures text is bright white
                backgroundColor: Colors.deepPurple,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 18), // CHANGE: Increased padding
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 5,
              ),
              onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Get Started', style: TextStyle(fontSize: 19)), // CHANGE: Increased font size
                  SizedBox(width: 10),
                  Icon(Icons.arrow_forward),
                ],
              ),
            ),
          ),
          const SizedBox(height: 60), // CHANGE: Increased bottom spacing
        ],
      ),
    );
  }
}

class _BottomWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 60);
    path.quadraticBezierTo(size.width / 2, size.height + 40, size.width, size.height - 60);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> old) => false;
}

// ─── Home Page (unchanged) ──────────────────────────────────────────────────

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  void _navigate(BuildContext context, String route) {
    Navigator.pushNamed(context, route);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Welcome, User!',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/weight'),
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.white, Colors.deepPurple.withOpacity(0.1)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4)),
                    ],
                  ),
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.show_chart, size: 64, color: Colors.deepPurpleAccent),
                        SizedBox(height: 8),
                        Text(
                          'View Your Progress',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'For you',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  children: [
                    _FeatureCard(
                      icon: Icons.fitness_center,
                      label: 'Exercises',
                      onTap: () => _navigate(context, '/exercises'),
                    ),
                    _FeatureCard(
                      icon: Icons.restaurant_menu,
                      label: 'Foods',
                      onTap: () => _navigate(context, '/recipes'),
                    ),
                    _FeatureCard(
                      icon: Icons.health_and_safety,
                      label: 'Sickness Signs',
                      onTap: () => _navigate(context, '/health'),
                    ),
                    _FeatureCard(
                      icon: Icons.monitor_weight,
                      label: 'Calculate BMI',
                      onTap: () => _navigate(context, '/bmi'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _FeatureCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 4,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: Colors.deepPurple[700]),
              const SizedBox(height: 12),
              Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ),
    );
  }
}
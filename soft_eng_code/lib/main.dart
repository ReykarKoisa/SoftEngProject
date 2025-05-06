// lib/main.dart
import 'package:flutter/material.dart';
import 'package:soft_eng_code/bmi_tracker.dart';  // ← your real BMI tracker widget

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
        '/':         (context) => const WelcomePage(),
        '/home':     (context) => const HomePage(),
        '/bmi':      (context) => const InputPage(),  // ← points to bmi_tracker.dart
        '/weight':   (context) => const PlaceholderScreen(title: 'Weight Tracker'),
        '/exercises':(context) => const PlaceholderScreen(title: 'Exercises'),
        '/recipes':  (context) => const PlaceholderScreen(title: 'Food Recipes'),
        '/health':   (context) => const PlaceholderScreen(title: 'Health Info'),
      },
    );
  }
}

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple[100],
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.fitness_center, size: 100, color: Colors.deepPurple[700]),
              const SizedBox(height: 24),
              const Text(
                'Welcome to Fitness App',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
                onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
                child: const Text('Enter App', style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  final List<_FeatureItem> features = const [
    _FeatureItem('BMI', Icons.monitor_weight, '/bmi'),
    _FeatureItem('Weight', Icons.scale, '/weight'),
    _FeatureItem('Exercises', Icons.fitness_center, '/exercises'),
    _FeatureItem('Recipes', Icons.restaurant_menu, '/recipes'),
    _FeatureItem('Health Info', Icons.health_and_safety, '/health'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home Page')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          children: features.map((item) => _buildFeatureCard(context, item)).toList(),
        ),
      ),
    );
  }

  Widget _buildFeatureCard(BuildContext context, _FeatureItem item) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, item.route),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(item.icon, size: 50, color: Colors.deepPurple[700]),
            const SizedBox(height: 12),
            Text(item.title, style: const TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}

class _FeatureItem {
  final String title;
  final IconData icon;
  final String route;
  const _FeatureItem(this.title, this.icon, this.route);
}

class PlaceholderScreen extends StatelessWidget {
  final String title;
  const PlaceholderScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text('This is the $title page')),
    );
  }
}




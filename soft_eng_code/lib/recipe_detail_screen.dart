import 'package:flutter/material.dart';

class SalmonSaladScreen extends StatelessWidget {
  const SalmonSaladScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _RecipeTemplate(
      title: 'Salmon Salad',
      imagePath: 'assets/images/salmon_salad.jpg',
      ingredients: [
        '1 grilled salmon fillet',
        '2 cups mixed greens',
        '1/2 avocado, sliced',
        'Cherry tomatoes',
        'Lemon vinaigrette',
      ],
      steps: [
        'Grill the salmon until cooked through.',
        'Toss greens with avocado and tomatoes.',
        'Top with salmon and drizzle dressing.',
      ],
    );
  }
}

class GrilledChickenScreen extends StatelessWidget {
  const GrilledChickenScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _RecipeTemplate(
      title: 'Grilled Chicken Bowl',
      imagePath: 'assets/images/grilled_chicken.jpg',
      ingredients: [
        '1 chicken breast, grilled',
        '1 cup brown rice',
        'Steamed broccoli',
        'Roasted bell peppers',
        'Yogurt sauce',
      ],
      steps: [
        'Grill chicken and slice into strips.',
        'Prepare rice and veggies.',
        'Arrange in a bowl and add yogurt sauce.',
      ],
    );
  }
}

class ShrimpTacosScreen extends StatelessWidget {
  const ShrimpTacosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _RecipeTemplate(
      title: 'Shrimp Tacos',
      imagePath: 'assets/images/shrimp_tacos.jpg',
      ingredients: [
        '12 shrimp, peeled and deveined',
        '2 small tortillas',
        '1/4 cup red cabbage, shredded',
        'Sliced avocado',
        'Lime wedges',
        'Sour cream or chipotle sauce',
      ],
      steps: [
        'Season and sauté shrimp until pink.',
        'Warm tortillas.',
        'Layer cabbage, shrimp, avocado.',
        'Top with sauce and squeeze lime.',
      ],
    );
  }
}

class BeefStirFryScreen extends StatelessWidget {
  const BeefStirFryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _RecipeTemplate(
      title: 'Beef Stir-Fry',
      imagePath: 'assets/images/beef_stirfry.jpg',
      ingredients: [
        '1 cup sliced beef',
        '1/2 bell pepper, sliced',
        '1/2 onion, sliced',
        'Soy sauce and garlic',
        '1 cup cooked rice',
      ],
      steps: [
        'Marinate beef in soy sauce and garlic.',
        'Stir-fry beef until browned.',
        'Add vegetables and cook until tender.',
        'Serve over rice.',
      ],
    );
  }
}

class ZucchiniPestoScreen extends StatelessWidget {
  const ZucchiniPestoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _RecipeTemplate(
      title: 'Zucchini Noodles with Pesto',
      imagePath: 'assets/images/zucchini_pesto.jpg',
      ingredients: [
        '2 zucchinis, spiralized',
        '1/4 cup pesto sauce',
        'Cherry tomatoes (optional)',
        'Parmesan cheese',
        'Salt and pepper',
      ],
      steps: [
        'Sauté zucchini noodles briefly.',
        'Add pesto and toss gently.',
        'Top with tomatoes and parmesan.',
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared Layout Template for Recipe Screens
// ─────────────────────────────────────────────────────────────────────────────

class _RecipeTemplate extends StatelessWidget {
  final String title;
  final String imagePath;
  final List<String> ingredients;
  final List<String> steps;

  const _RecipeTemplate({
    required this.title,
    required this.imagePath,
    required this.ingredients,
    required this.steps,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.deepPurple,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.asset(imagePath, fit: BoxFit.cover),
          ),
          const SizedBox(height: 24),
          Text('Ingredients', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          ...ingredients.map((item) => ListTile(
            leading: const Icon(Icons.check_circle_outline, color: Colors.deepPurple),
            title: Text(item),
          )),
          const SizedBox(height: 16),
          Text('Steps', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          ...steps.asMap().entries.map((e) => ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
              child: Text('${e.key + 1}'),
            ),
            title: Text(e.value),
          )),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:soft_eng_code/recipe_detail_screen.dart';

class RecipeListScreen extends StatelessWidget {
  const RecipeListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> recipes = [
      {
        'title': 'Salmon Salad',
        'image': 'assets/images/salmon_salad.jpg',
        'screen': const SalmonSaladScreen(),
        'description':
        'A nutritious blend of flaked salmon, fresh greens, cherry tomatoes, cucumbers, and creamy avocado, drizzled with a zesty lemon-Dijon dressing.',
      },
      {
        'title': 'Grilled Chicken Bowl',
        'image': 'assets/images/grilled_chicken.jpg',
        'screen': const GrilledChickenScreen(),
        'description':
        'A wholesome bowl with quinoa, grilled chicken, and mixed vegetables tossed in a light dressing.',
      },
      {
        'title': 'Shrimp Tacos',
        'image': 'assets/images/shrimp_tacos.jpg',
        'screen': const ShrimpTacosScreen(),
        'description':
        'Seasoned shrimp, crunchy cabbage, and avocado in warm tortillas, topped with lime crema.',
      },
      {
        'title': 'Beef Stir-Fry',
        'image': 'assets/images/beef_stirfry.jpg',
        'screen': const BeefStirFryScreen(),
        'description':
        'Tender beef strips stir-fried with bell peppers, broccoli, and snap peas in savory soy sauce.',
      },
      {
        'title': 'Zucchini with Pesto',
        'image': 'assets/images/zucchini_pesto.jpg',
        'screen': const ZucchiniPestoScreen(),
        'description':
        'Zucchini noodles tossed with basil pesto, cherry tomatoes, and pine nuts. Serve warm or chilled!',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Healthy Recipes'),
        backgroundColor: Colors.deepPurple,
      ),
      backgroundColor: const Color(0xFFE6DFF1),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 16),
            child: Text(
              'Recipe List!!',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w800,
                color: Colors.black,
              ),
            ),
          ),
          ...recipes.map((recipe) {
            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 4,
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => recipe['screen'] as Widget),
                  );
                },
                borderRadius: BorderRadius.circular(16),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        bottomLeft: Radius.circular(16),
                      ),
                      child: Image.asset(
                        recipe['image'] as String,
                        width: 120,
                        height: 150,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              recipe['title'] as String,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              recipe['description'] as String,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios, color: Colors.deepPurple),
                    const SizedBox(width: 12),
                  ],
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}

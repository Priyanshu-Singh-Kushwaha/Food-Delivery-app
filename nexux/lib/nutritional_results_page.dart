import 'package:flutter/material.dart';
import 'dart:ui';

class NutritionalResultPage extends StatelessWidget {
  final Map<String, dynamic> nutritionalData;

  const NutritionalResultPage({
    super.key,
    required this.nutritionalData,
  });

  @override
  Widget build(BuildContext context) {
    final String foodName = nutritionalData['foodName'] ?? 'Unknown Food Item';
    final int calories = nutritionalData['calories'] ?? 0;
    final int protein = nutritionalData['protein'] ?? 0;
    final int carbs = nutritionalData['carbs'] ?? 0;
    final int fats = nutritionalData['fats'] ?? 0;
    final int fiber = nutritionalData['fiber'] ?? 0;
    final int sugars = nutritionalData['sugars'] ?? 0;
    final int sodium = nutritionalData['sodium'] ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nutritional Analysis'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Icon(
                Icons.check_circle_outline_rounded,
                size: 80,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 15),
            Center(
              child: Text(
                'Scan Complete: AI Report Generated',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 30),

            Card(
              elevation: 10,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
                side: BorderSide(color: Colors.white.withOpacity(0.08), width: 0.5),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      foodName,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const Divider(height: 25, thickness: 1.5, color: Colors.white12),
                    const SizedBox(height: 10),

                    _buildNutrientRow(context, 'Calories', '$calories kcal', Icons.local_fire_department_rounded, Theme.of(context).colorScheme.secondary),
                    _buildNutrientRow(context, 'Protein', '$protein g', Icons.fitness_center_rounded, Colors.greenAccent),
                    _buildNutrientRow(context, 'Carbohydrates', '$carbs g', Icons.grain_rounded, Colors.orangeAccent),
                    _buildNutrientRow(context, 'Fats', '$fats g', Icons.opacity_rounded, Colors.blueGrey),
                    _buildNutrientRow(context, 'Fiber', '$fiber g', Icons.grass_rounded, Colors.lightGreenAccent),
                    _buildNutrientRow(context, 'Sugars', '$sugars g', Icons.cookie_rounded, Colors.pinkAccent),
                    _buildNutrientRow(context, 'Sodium', '$sodium mg', Icons.water_drop_rounded, Colors.purpleAccent),

                    const SizedBox(height: 20),
                    Center(
                      child: Text(
                        'Detailed breakdown provided by Nexus AI.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic, color: Colors.white54),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
                icon: Icon(Icons.add_task_rounded, color: Theme.of(context).colorScheme.onSecondary),
                label: Text(
                  'Add to Daily Log',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSecondary,
                      ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  elevation: 8,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNutrientRow(BuildContext context, String title, String value, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }
}

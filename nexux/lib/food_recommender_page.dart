import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:ui';
import 'package:nexux/nutritional_results_page.dart';
import 'package:nexux/services/gemini_service.dart';
import 'package:provider/provider.dart';
import 'package:nexux/services/firestore_service.dart';
import 'package:nexux/models/food_analysis_result.dart';

typedef VitalsUpdateCallback = void Function(Map<String, dynamic> nutritionalData);

class FoodRecommenderPage extends StatefulWidget {
  final VitalsUpdateCallback onVitalsUpdate;
  final Map<String, dynamic> currentVitals;

  const FoodRecommenderPage({
    super.key,
    required this.onVitalsUpdate,
    required this.currentVitals,
  });

  @override
  State<FoodRecommenderPage> createState() => _FoodRecommenderPageState();
}

class _FoodRecommenderPageState extends State<FoodRecommenderPage> {
  final ImagePicker _picker = ImagePicker();
  final GeminiService _geminiService = GeminiService();
  List<Map<String, String>> _getAdaptiveRecommendations() {
    final recommendationsPool = {
      'low-carb': {
        'name': 'Avocado & Chicken Salad',
        'details': 'Low-carb, high in healthy fats and protein.',
        'image': 'https://via.placeholder.com/150/8BC34A/000000?text=Low+Carb',
      },
      'high-protein': {
        'name': 'Protein Power Shake',
        'details': 'Ideal for muscle recovery. Low on carbs.',
        'image': 'https://via.placeholder.com/150/7C4DFF/FFFFFF?text=Protein',
      },
      'balanced': {
        'name': 'Quinoa Power Bowl',
        'details': 'A perfect balance of carbs, fats, and protein.',
        'image': 'https://via.placeholder.com/150/FF9800/000000?text=Balanced',
      },
      'energy-boost': {
        'name': 'Fruity Oatmeal',
        'details': 'High in complex carbs for sustained energy.',
        'image': 'https://via.placeholder.com/150/00BCD4/000000?text=Energy',
      }
    };
    final vitals = widget.currentVitals;
    int carbs = vitals['Carbs']['value'] as int;
    int targetCarbs = vitals['Carbs']['target'] as int;
    int protein = vitals['Proteins']['value'] as int;
    int targetProtein = vitals['Proteins']['target'] as int;

    List<Map<String, String>> adaptiveList = [];

    if (carbs > (targetCarbs * 0.75)) {
      adaptiveList.add(recommendationsPool['low-carb']!);
      adaptiveList.add(recommendationsPool['high-protein']!);
    } else if (protein < (targetProtein * 0.4)) {
      adaptiveList.add(recommendationsPool['high-protein']!);
      adaptiveList.add(recommendationsPool['balanced']!);
    } else {
      adaptiveList.add(recommendationsPool['balanced']!);
      adaptiveList.add(recommendationsPool['energy-boost']!);
    }

    return adaptiveList;
  }
  void _pickImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);

    if (image != null) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Theme.of(context).colorScheme.surface,
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary),
                ),
                const SizedBox(height: 20),
                Text(
                  'Sending image to Gemini AI for analysis...',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white),
                ),
                Text(
                  'Please wait for detailed nutritional insights.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white70),
                ),
              ],
            ),
          );
        },
      );

      try {
        final Map<String, dynamic> nutritionalData = await _geminiService.analyzeFoodImage(image.path);

        if (mounted) Navigator.of(context).pop();

        final firestoreService = Provider.of<FirestoreService>(context, listen: false);
        final foodAnalysisResult = FoodAnalysisResult(
          foodName: nutritionalData['foodName'] ?? 'Unidentified Meal',
          calories: nutritionalData['calories'] ?? 0,
          protein: nutritionalData['protein'] ?? 0,
          carbs: nutritionalData['carbs'] ?? 0,
          fats: nutritionalData['fats'] ?? 0,
          fiber: nutritionalData['fiber'] ?? 0,
          sugars: nutritionalData['sugars'] ?? 0,
          sodium: nutritionalData['sodium'] ?? 0,
          timestamp: DateTime.now(),
        );
        await firestoreService.addFoodAnalysisResult(foodAnalysisResult);

        if (mounted) {
          final bool? addedToLog = await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => NutritionalResultPage( 
                nutritionalData: nutritionalData,
              ),
            ),
          );

          if (addedToLog == true) {
            widget.onVitalsUpdate(nutritionalData); 
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Vitals updated with ${nutritionalData['foodName']} data!'),
                backgroundColor: Theme.of(context).colorScheme.primary,
                duration: const Duration(seconds: 2),
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error analyzing food: $e. Using fallback.'),
            backgroundColor: Theme.of(context).colorScheme.error,
            duration: const Duration(seconds: 4),
          ),
        );
        print('Error details: $e');
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No image selected.'),
          backgroundColor: Colors.grey[700],
        ),
      );
    }
  }
  void _showImagePickerDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface.withOpacity(0.9),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  'Select Image Source',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white),
                ),
                const Divider(color: Colors.white12, height: 30, thickness: 1),
                ListTile(
                  leading: Icon(Icons.camera_alt_rounded, color: Theme.of(context).colorScheme.primary),
                  title: Text('Take a Picture', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white)),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.photo_library_rounded, color: Theme.of(context).colorScheme.primary),
                  title: Text('Choose from Gallery', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white)),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.gallery);
                  },
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> recommendedFoods = _getAdaptiveRecommendations();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primary.withOpacity(0.7),
                    Theme.of(context).colorScheme.secondary.withOpacity(0.7),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.4),
                    blurRadius: 20,
                    spreadRadius: 2,
                    offset: const Offset(0, 10),
                  ),
                ],
                border: Border.all(
                    color: Colors.white.withOpacity(0.1), width: 0.8),
              ),
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(25),
                child: InkWell(
                  borderRadius: BorderRadius.circular(25),
                  onTap: _showImagePickerDialog,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 30),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.camera_enhance_rounded,
                          size: 70,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                        const SizedBox(height: 15),
                        Text(
                          'Analyze Nutritional Data',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: Theme.of(context).colorScheme.onPrimary,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.8,
                              ),
                        ),
                        const Text(
                          'Powered by Advanced AI Protocols',
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 15,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 50),

          Text(
            'Adaptive Dietary Recommendations',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white),
          ),
          const Divider(height: 30, thickness: 1.8, color: Colors.white12),
          const SizedBox(height: 20),          
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: recommendedFoods.length,
            itemBuilder: (context, index) {
              final food = recommendedFoods[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 10.0),
                elevation: 8,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                child: Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          food['image']!,
                          width: 90,
                          height: 90,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Icon(Icons.broken_image, size: 90, color: Colors.grey[700]),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              food['name']!,
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: Theme.of(context).colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.8,
                                  ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              food['details']!,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.white70,
                                  ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 15),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: Icon(Icons.shopping_bag_rounded,
                                color: Theme.of(context).colorScheme.secondary, size: 32),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Initiating order for ${food['name']}...'),
                                  backgroundColor: Theme.of(context).colorScheme.secondary,
                                  duration: const Duration(seconds: 1),
                                ),
                              );
                            },
                            tooltip: 'Order Via Network',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
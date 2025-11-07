class FoodAnalysisResult {
  final String? id;
  final String foodName;
  final int calories;
  final int protein;
  final int carbs;
  final int fats;
  final int fiber;
  final int sugars;
  final int sodium;
  final DateTime timestamp;

  FoodAnalysisResult({
    this.id,
    required this.foodName,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fats,
    required this.fiber,
    required this.sugars,
    required this.sodium,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'foodName': foodName,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fats': fats,
      'fiber': fiber,
      'sugars': sugars,
      'sodium': sodium,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory FoodAnalysisResult.fromJson(Map<String, dynamic> json) {
    return FoodAnalysisResult(
      id: json['id'],
      foodName: json['foodName'] ?? 'Unknown Food',
      calories: json['calories'] ?? 0,
      protein: json['protein'] ?? 0,
      carbs: json['carbs'] ?? 0,
      fats: json['fats'] ?? 0,
      fiber: json['fiber'] ?? 0,
      sugars: json['sugars'] ?? 0,
      sodium: json['sodium'] ?? 0,
      timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
    );
  }
}
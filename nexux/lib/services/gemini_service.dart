import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';

class GeminiService {
  static const String _geminiApiKey = '#';
  static const String _geminiApiEndpoint = '#';

  Future<Map<String, dynamic>> analyzeFoodImage(String imagePath) async {
    print('Attempting to analyze image from path: $imagePath');

    File imageFile = File(imagePath);
    List<int> imageBytes;
    try {
      imageBytes = await imageFile.readAsBytes();
      print('Successfully read image bytes. Size: ${imageBytes.length} bytes.');
    } catch (e) {
      print('Error reading image file at $imagePath: $e');
      return _getFallbackSimulatedData('File read error: $e');
    }
    String base64Image = base64Encode(imageBytes);
    print('Image successfully converted to base64.');

    final Map<String, dynamic> requestBody = {
      "contents": [
        {
          "parts": [
            {"text": "Analyze the nutritional content of the food in this image. Provide a summary with food name, total calories, protein in grams, carbohydrates in grams, fats in grams, fiber in grams, sugars in grams, and sodium in milligrams. Present it in a concise JSON format like: {\"foodName\": \"\", \"calories\": 0, \"protein\": 0, \"carbs\": 0, \"fats\": 0, \"fiber\": 0, \"sugars\": 0, \"sodium\": 0}. If you cannot identify, use 'Unidentified Meal' and provide sensible defaults, ensuring numbers are integers."},
            {
              "inline_data": {
                "mime_type": "image/jpeg",
                "data": base64Image,
              }
            }
          ]
        }
      ]
    };

    try {
      final response = await http.post(
        Uri.parse(_geminiApiEndpoint),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        String textResponse = responseData['candidates'][0]['content']['parts'][0]['text'];
        print('Gemini API raw text response: $textResponse');

        final jsonStartIndex = textResponse.indexOf('{');
        final jsonEndIndex = textResponse.lastIndexOf('}');

        if (jsonStartIndex != -1 && jsonEndIndex != -1 && jsonEndIndex > jsonStartIndex) {
          String jsonString = textResponse.substring(jsonStartIndex, jsonEndIndex + 1);
          try {
            Map<String, dynamic> parsedData = jsonDecode(jsonString);
            print('Successfully parsed JSON from Gemini response.');

            return {
              'foodName': parsedData['foodName'] ?? 'Unidentified Meal (AI Error)',
              'calories': (parsedData['calories'] is num) ? parsedData['calories'].toInt() : 0,
              'protein': (parsedData['protein'] is num) ? parsedData['protein'].toInt() : 0,
              'carbs': (parsedData['carbs'] is num) ? parsedData['carbs'].toInt() : 0,
              'fats': (parsedData['fats'] is num) ? parsedData['fats'].toInt() : 0,
              'fiber': (parsedData['fiber'] is num) ? parsedData['fiber'].toInt() : 0,
              'sugars': (parsedData['sugars'] is num) ? parsedData['sugars'].toInt() : 0,
              'sodium': (parsedData['sodium'] is num) ? parsedData['sodium'].toInt() : 0,
            };
          } catch (e) {
            print('Error parsing JSON from Gemini response: $e');
            return _getFallbackSimulatedData('JSON parsing error');
          }
        } else {
          print('Could not find JSON in Gemini response.');
          return _getFallbackSimulatedData('No JSON in response');
        }
      } else {
        print('Gemini API Error: ${response.statusCode}');
        print('Response Body: ${response.body}');
        return _getFallbackSimulatedData('API error: ${response.statusCode}');
      }
    } catch (e) {
        print('Network or other error during API call: $e');
        return _getFallbackSimulatedData('Network error');
    }
  }
  Map<String, dynamic> _getFallbackSimulatedData(String reason) {
    print('Falling back to smart simulated data. Reason: $reason');

    final List<Map<String, dynamic>> sampleFoods = [
      {
        'foodName': 'Cheesy Pizza Slice (Simulated)',
        'calories': 285,
        'protein': 12,
        'carbs': 36,
        'fats': 10,
        'fiber': 2,
        'sugars': 5,
        'sodium': 640,
      },
      {
        'foodName': 'Grilled Chicken Salad (Simulated)',
        'calories': 320,
        'protein': 30,
        'carbs': 10,
        'fats': 18,
        'fiber': 5,
        'sugars': 4,
        'sodium': 350,
      },
      {
        'foodName': 'Classic Beef Burger (Simulated)',
        'calories': 550,
        'protein': 25,
        'carbs': 40,
        'fats': 30,
        'fiber': 3,
        'sugars': 8,
        'sodium': 980,
      },
      {
        'foodName': 'Vegetable Stir-fry (Simulated)',
        'calories': 250,
        'protein': 8,
        'carbs': 25,
        'fats': 12,
        'fiber': 6,
        'sugars': 9,
        'sodium': 500,
      }
    ];
    final random = Random();
    final selectedFood = sampleFoods[random.nextInt(sampleFoods.length)];

    return selectedFood;
  }
}
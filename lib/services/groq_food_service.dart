import 'dart:convert';
import 'package:http/http.dart' as http;

class ScannedFood {
  final String name;
  final int estimatedCalories;
  final int? protein;
  final int? carbs;
  final int? fat;
  final String? servingSize;
  final String confidence;

  ScannedFood({
    required this.name,
    required this.estimatedCalories,
    this.protein,
    this.carbs,
    this.fat,
    this.servingSize,
    required this.confidence,
  });

  factory ScannedFood.fromJson(Map<String, dynamic> json) {
    return ScannedFood(
      name: json['name'] ?? 'Unknown Food',
      estimatedCalories: json['calories'] ?? 0,
      protein: json['protein'],
      carbs: json['carbs'],
      fat: json['fat'],
      servingSize: json['serving_size'],
      confidence: json['confidence'] ?? 'medium',
    );
  }
}

class GroqFoodService {
  static const String _baseUrl = 'https://api.groq.com/openai/v1/chat/completions';

  // User should set their own API key
  static String? _apiKey;

  static void setApiKey(String key) {
    _apiKey = key;
  }

  static bool get hasApiKey => _apiKey != null && _apiKey!.isNotEmpty;

  /// Analyze food from a base64 encoded image
  static Future<List<ScannedFood>> analyzeImage(String base64Image) async {
    if (!hasApiKey) {
      throw Exception('Groq API key not set. Please add your API key in Settings.');
    }

    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': 'meta-llama/llama-4-scout-17b-16e-instruct',
          'messages': [
            {
              'role': 'system',
              'content': '''You are a nutrition expert AI that analyzes food images.
When given an image of food, identify all visible food items and estimate their nutritional content.
Respond ONLY with a JSON array of food items. Each item should have:
- name: string (the food name)
- calories: number (estimated calories)
- protein: number (grams of protein)
- carbs: number (grams of carbohydrates)
- fat: number (grams of fat)
- serving_size: string (estimated portion size)
- confidence: string ("high", "medium", or "low")

Example response:
[{"name": "Grilled Chicken Breast", "calories": 165, "protein": 31, "carbs": 0, "fat": 4, "serving_size": "100g", "confidence": "high"}]

If you cannot identify any food, respond with an empty array: []'''
            },
            {
              'role': 'user',
              'content': [
                {
                  'type': 'text',
                  'text': 'Analyze this food image and provide nutritional estimates for all visible food items.'
                },
                {
                  'type': 'image_url',
                  'image_url': {
                    'url': 'data:image/jpeg;base64,$base64Image'
                  }
                }
              ]
            }
          ],
          'max_tokens': 1024,
          'temperature': 0.1,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'] as String;

        // Parse the JSON response
        try {
          // Extract JSON from the response (in case there's extra text)
          final jsonMatch = RegExp(r'\[[\s\S]*\]').firstMatch(content);
          if (jsonMatch != null) {
            final List<dynamic> foods = jsonDecode(jsonMatch.group(0)!);
            return foods.map((f) => ScannedFood.fromJson(f)).toList();
          }
        } catch (e) {
          print('Error parsing food response: $e');
        }
        return [];
      } else {
        print('Groq API Error: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to analyze image: ${response.statusCode}');
      }
    } catch (e) {
      print('Groq API Exception: $e');
      rethrow;
    }
  }

  /// Analyze food from a text description
  static Future<List<ScannedFood>> analyzeDescription(String description) async {
    if (!hasApiKey) {
      throw Exception('Groq API key not set. Please add your API key in Settings.');
    }

    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': 'meta-llama/llama-4-scout-17b-16e-instruct',
          'messages': [
            {
              'role': 'system',
              'content': '''You are a nutrition expert AI. When given a food description, estimate its nutritional content.
Respond ONLY with a JSON array of food items. Each item should have:
- name: string (the food name)
- calories: number (estimated calories)
- protein: number (grams of protein)
- carbs: number (grams of carbohydrates)
- fat: number (grams of fat)
- serving_size: string (estimated portion size)
- confidence: string ("high", "medium", or "low")

Be accurate with calorie estimates based on standard serving sizes.'''
            },
            {
              'role': 'user',
              'content': 'Estimate the nutrition for: $description'
            }
          ],
          'max_tokens': 512,
          'temperature': 0.1,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'] as String;

        try {
          final jsonMatch = RegExp(r'\[[\s\S]*\]').firstMatch(content);
          if (jsonMatch != null) {
            final List<dynamic> foods = jsonDecode(jsonMatch.group(0)!);
            return foods.map((f) => ScannedFood.fromJson(f)).toList();
          }
        } catch (e) {
          print('Error parsing food response: $e');
        }
        return [];
      } else {
        throw Exception('Failed to analyze description: ${response.statusCode}');
      }
    } catch (e) {
      print('Groq API Exception: $e');
      rethrow;
    }
  }
}

import 'dart:convert';
import 'package:http/http.dart' as http;

class USDAFoodItem {
  final String fdcId;
  final String description;
  final String? brandName;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final double? fiber;
  final String servingSize;
  final double servingWeight;

  USDAFoodItem({
    required this.fdcId,
    required this.description,
    this.brandName,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    this.fiber,
    required this.servingSize,
    required this.servingWeight,
  });

  String get displayName => brandName != null ? '$description ($brandName)' : description;

  factory USDAFoodItem.fromJson(Map<String, dynamic> json) {
    // Extract nutrients
    double calories = 0;
    double protein = 0;
    double carbs = 0;
    double fat = 0;
    double? fiber;

    final nutrients = json['foodNutrients'] as List<dynamic>? ?? [];
    for (final nutrient in nutrients) {
      final nutrientId = nutrient['nutrientId'] ?? nutrient['nutrient']?['id'];
      final value = (nutrient['value'] ?? nutrient['amount'] ?? 0).toDouble();

      switch (nutrientId) {
        case 1008: // Energy (kcal)
          calories = value;
          break;
        case 1003: // Protein
          protein = value;
          break;
        case 1005: // Carbohydrates
          carbs = value;
          break;
        case 1004: // Total fat
          fat = value;
          break;
        case 1079: // Fiber
          fiber = value;
          break;
      }
    }

    // Get serving size info
    String servingSize = '100g';
    double servingWeight = 100.0;

    final servingSizeUnit = json['servingSizeUnit'];
    final servingSizeValue = json['servingSize'];
    if (servingSizeValue != null) {
      servingWeight = (servingSizeValue as num).toDouble();
      servingSize = '$servingWeight${servingSizeUnit ?? 'g'}';
    }

    // Check for household serving
    final householdServing = json['householdServingFullText'];
    if (householdServing != null) {
      servingSize = householdServing;
    }

    return USDAFoodItem(
      fdcId: json['fdcId'].toString(),
      description: json['description'] ?? 'Unknown Food',
      brandName: json['brandName'] ?? json['brandOwner'],
      calories: calories,
      protein: protein,
      carbs: carbs,
      fat: fat,
      fiber: fiber,
      servingSize: servingSize,
      servingWeight: servingWeight,
    );
  }

  // Calculate calories for a given quantity (based on 100g reference)
  int caloriesForQuantity(double quantity) {
    return (calories * quantity).round();
  }
}

class USDAFoodService {
  // USDA FoodData Central API - Free API key (demo key, works for basic usage)
  static const String _apiKey = 'DEMO_KEY';
  static const String _baseUrl = 'https://api.nal.usda.gov/fdc/v1';

  // Search for foods
  static Future<List<USDAFoodItem>> searchFoods(String query, {int pageSize = 25}) async {
    if (query.trim().isEmpty) return [];

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/foods/search?api_key=$_apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'query': query,
          'pageSize': pageSize,
          'dataType': ['Foundation', 'SR Legacy', 'Branded'],
          'sortBy': 'dataType.keyword',
          'sortOrder': 'asc',
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final foods = data['foods'] as List<dynamic>? ?? [];
        return foods.map((f) => USDAFoodItem.fromJson(f)).toList();
      } else {
        print('USDA API Error: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('USDA API Exception: $e');
      return [];
    }
  }

  // Get detailed food info by FDC ID
  static Future<USDAFoodItem?> getFoodDetails(String fdcId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/food/$fdcId?api_key=$_apiKey'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return USDAFoodItem.fromJson(data);
      }
      return null;
    } catch (e) {
      print('USDA API Exception: $e');
      return null;
    }
  }
}

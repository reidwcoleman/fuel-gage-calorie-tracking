import 'package:uuid/uuid.dart';

enum MealType { breakfast, lunch, dinner, snack }

extension MealTypeExtension on MealType {
  String get displayName {
    switch (this) {
      case MealType.breakfast:
        return 'Breakfast';
      case MealType.lunch:
        return 'Lunch';
      case MealType.dinner:
        return 'Dinner';
      case MealType.snack:
        return 'Snack';
    }
  }

  String get icon {
    switch (this) {
      case MealType.breakfast:
        return '🌅';
      case MealType.lunch:
        return '☀️';
      case MealType.dinner:
        return '🌙';
      case MealType.snack:
        return '🍎';
    }
  }
}

class FoodEntry {
  final String id;
  final String foodName;
  final int calories;
  final MealType mealType;
  final DateTime timestamp;
  final double quantity;
  final String unit;

  FoodEntry({
    String? id,
    required this.foodName,
    required this.calories,
    required this.mealType,
    DateTime? timestamp,
    this.quantity = 1.0,
    this.unit = 'serving',
  })  : id = id ?? const Uuid().v4(),
        timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'foodName': foodName,
        'calories': calories,
        'mealType': mealType.index,
        'timestamp': timestamp.toIso8601String(),
        'quantity': quantity,
        'unit': unit,
      };

  factory FoodEntry.fromJson(Map<String, dynamic> json) => FoodEntry(
        id: json['id'],
        foodName: json['foodName'],
        calories: json['calories'],
        mealType: MealType.values[json['mealType']],
        timestamp: DateTime.parse(json['timestamp']),
        quantity: (json['quantity'] as num).toDouble(),
        unit: json['unit'],
      );

  FoodEntry copyWith({
    String? id,
    String? foodName,
    int? calories,
    MealType? mealType,
    DateTime? timestamp,
    double? quantity,
    String? unit,
  }) {
    return FoodEntry(
      id: id ?? this.id,
      foodName: foodName ?? this.foodName,
      calories: calories ?? this.calories,
      mealType: mealType ?? this.mealType,
      timestamp: timestamp ?? this.timestamp,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
    );
  }
}

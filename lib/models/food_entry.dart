import 'package:uuid/uuid.dart';

class FoodEntry {
  final String id;
  final String foodName;
  final int calories;
  final DateTime timestamp;
  final double quantity;
  final String unit;

  FoodEntry({
    String? id,
    required this.foodName,
    required this.calories,
    DateTime? timestamp,
    this.quantity = 1.0,
    this.unit = 'serving',
  })  : id = id ?? const Uuid().v4(),
        timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'foodName': foodName,
        'calories': calories,
        'timestamp': timestamp.toIso8601String(),
        'quantity': quantity,
        'unit': unit,
      };

  factory FoodEntry.fromJson(Map<String, dynamic> json) => FoodEntry(
        id: json['id'],
        foodName: json['foodName'],
        calories: json['calories'],
        timestamp: DateTime.parse(json['timestamp']),
        quantity: (json['quantity'] as num).toDouble(),
        unit: json['unit'],
      );

  FoodEntry copyWith({
    String? id,
    String? foodName,
    int? calories,
    DateTime? timestamp,
    double? quantity,
    String? unit,
  }) {
    return FoodEntry(
      id: id ?? this.id,
      foodName: foodName ?? this.foodName,
      calories: calories ?? this.calories,
      timestamp: timestamp ?? this.timestamp,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
    );
  }
}

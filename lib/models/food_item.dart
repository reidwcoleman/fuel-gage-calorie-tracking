class FoodItem {
  final String id;
  final String name;
  final int caloriesPer100g;
  final String category;
  final String? servingSize;
  final int? caloriesPerServing;

  const FoodItem({
    required this.id,
    required this.name,
    required this.caloriesPer100g,
    required this.category,
    this.servingSize,
    this.caloriesPerServing,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'caloriesPer100g': caloriesPer100g,
        'category': category,
        'servingSize': servingSize,
        'caloriesPerServing': caloriesPerServing,
      };

  factory FoodItem.fromJson(Map<String, dynamic> json) => FoodItem(
        id: json['id'],
        name: json['name'],
        caloriesPer100g: json['caloriesPer100g'],
        category: json['category'],
        servingSize: json['servingSize'],
        caloriesPerServing: json['caloriesPerServing'],
      );

  FoodItem copyWith({
    String? id,
    String? name,
    int? caloriesPer100g,
    String? category,
    String? servingSize,
    int? caloriesPerServing,
  }) {
    return FoodItem(
      id: id ?? this.id,
      name: name ?? this.name,
      caloriesPer100g: caloriesPer100g ?? this.caloriesPer100g,
      category: category ?? this.category,
      servingSize: servingSize ?? this.servingSize,
      caloriesPerServing: caloriesPerServing ?? this.caloriesPerServing,
    );
  }
}

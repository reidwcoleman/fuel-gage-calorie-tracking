import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../data/food_database.dart';
import '../models/food_entry.dart';
import '../models/food_item.dart';
import '../providers/calorie_provider.dart';
import '../theme/app_theme.dart';

class AddFoodScreen extends StatefulWidget {
  final MealType mealType;

  const AddFoodScreen({super.key, required this.mealType});

  @override
  State<AddFoodScreen> createState() => _AddFoodScreenState();
}

class _AddFoodScreenState extends State<AddFoodScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _customNameController = TextEditingController();
  final TextEditingController _customCaloriesController = TextEditingController();

  String _searchQuery = '';
  String? _selectedCategory;
  bool _showCustomEntry = false;

  @override
  void dispose() {
    _searchController.dispose();
    _customNameController.dispose();
    _customCaloriesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add to ${widget.mealType.displayName}'),
        actions: [
          TextButton(
            onPressed: () => setState(() => _showCustomEntry = !_showCustomEntry),
            child: Text(
              _showCustomEntry ? 'Search Foods' : 'Custom Entry',
              style: const TextStyle(color: AppTheme.accent),
            ),
          ),
        ],
      ),
      body: _showCustomEntry ? _buildCustomEntryForm() : _buildFoodSearch(),
    );
  }

  Widget _buildFoodSearch() {
    final filteredFoods = _getFilteredFoods();
    final categories = FoodDatabase.categories;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _searchController,
            onChanged: (value) => setState(() => _searchQuery = value),
            decoration: InputDecoration(
              hintText: 'Search foods...',
              prefixIcon: const Icon(Icons.search, color: AppTheme.textMuted),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: AppTheme.textMuted),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                    )
                  : null,
            ),
          ),
        ),
        if (_searchQuery.isEmpty) ...[
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: categories.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return _buildCategoryChip('All', _selectedCategory == null);
                }
                final category = categories[index - 1];
                return _buildCategoryChip(
                  category,
                  _selectedCategory == category,
                );
              },
            ),
          ),
          const SizedBox(height: 8),
        ],
        Expanded(
          child: filteredFoods.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  itemCount: filteredFoods.length,
                  itemBuilder: (context, index) {
                    return _buildFoodTile(filteredFoods[index]);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildCategoryChip(String label, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedCategory = selected && label != 'All' ? label : null;
          });
        },
        selectedColor: AppTheme.primaryGreen.withOpacity(0.3),
        checkmarkColor: AppTheme.primaryGreen,
        labelStyle: TextStyle(
          color: isSelected ? AppTheme.primaryGreen : AppTheme.textSecondary,
        ),
        backgroundColor: AppTheme.surfaceLight,
        side: BorderSide.none,
      ),
    );
  }

  Widget _buildFoodTile(FoodItem food) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        title: Text(
          food.name,
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          food.servingSize ?? '100g',
          style: const TextStyle(
            color: AppTheme.textMuted,
            fontSize: 12,
          ),
        ),
        trailing: Text(
          '${food.caloriesPerServing ?? food.caloriesPer100g} cal',
          style: const TextStyle(
            color: AppTheme.primaryGreen,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        onTap: () => _showQuantityDialog(food),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.search_off,
            size: 64,
            color: AppTheme.textMuted,
          ),
          const SizedBox(height: 16),
          const Text(
            'No foods found',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => setState(() => _showCustomEntry = true),
            child: const Text('Add custom entry'),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomEntryForm() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Quick Add',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Enter a food name and calories to quickly log it.',
            style: TextStyle(color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _customNameController,
            decoration: const InputDecoration(
              labelText: 'Food name',
              hintText: 'e.g., Homemade soup',
            ),
            textCapitalization: TextCapitalization.sentences,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _customCaloriesController,
            decoration: const InputDecoration(
              labelText: 'Calories',
              hintText: 'e.g., 250',
              suffixText: 'cal',
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: _addCustomEntry,
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 4),
              child: Text(
                'Add Food',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<FoodItem> _getFilteredFoods() {
    if (_searchQuery.isNotEmpty) {
      return FoodDatabase.search(_searchQuery);
    }
    if (_selectedCategory != null) {
      return FoodDatabase.getByCategory(_selectedCategory!);
    }
    return FoodDatabase.foods;
  }

  void _showQuantityDialog(FoodItem food) {
    double quantity = 1.0;
    final servingCalories = food.caloriesPerServing ?? food.caloriesPer100g;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final totalCalories = (servingCalories * quantity).round();

            return AlertDialog(
              backgroundColor: AppTheme.cardBackground,
              title: Text(
                food.name,
                style: const TextStyle(color: AppTheme.textPrimary),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    food.servingSize ?? '100g serving',
                    style: const TextStyle(color: AppTheme.textSecondary),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: quantity > 0.5
                            ? () => setDialogState(() => quantity -= 0.5)
                            : null,
                        icon: const Icon(Icons.remove_circle_outline),
                        iconSize: 32,
                        color: AppTheme.primaryGreen,
                      ),
                      const SizedBox(width: 16),
                      Text(
                        quantity.toString(),
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 16),
                      IconButton(
                        onPressed: () => setDialogState(() => quantity += 0.5),
                        icon: const Icon(Icons.add_circle_outline),
                        iconSize: 32,
                        color: AppTheme.primaryGreen,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '$totalCalories calories',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryGreen,
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    _addFoodEntry(food, quantity, totalCalories);
                    Navigator.pop(context);
                  },
                  child: const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _addFoodEntry(FoodItem food, double quantity, int calories) {
    final entry = FoodEntry(
      foodName: food.name,
      calories: calories,
      mealType: widget.mealType,
      quantity: quantity,
      unit: food.servingSize != null ? 'serving' : '100g',
    );

    context.read<CalorieProvider>().addFoodEntry(entry);
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${food.name} added to ${widget.mealType.displayName}'),
        backgroundColor: AppTheme.primaryGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _addCustomEntry() {
    final name = _customNameController.text.trim();
    final caloriesText = _customCaloriesController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a food name'),
          backgroundColor: AppTheme.dangerRed,
        ),
      );
      return;
    }

    if (caloriesText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter calories'),
          backgroundColor: AppTheme.dangerRed,
        ),
      );
      return;
    }

    final calories = int.tryParse(caloriesText) ?? 0;
    if (calories <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid calorie amount'),
          backgroundColor: AppTheme.dangerRed,
        ),
      );
      return;
    }

    final entry = FoodEntry(
      foodName: name,
      calories: calories,
      mealType: widget.mealType,
      quantity: 1,
      unit: 'serving',
    );

    context.read<CalorieProvider>().addFoodEntry(entry);
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$name added to ${widget.mealType.displayName}'),
        backgroundColor: AppTheme.primaryGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}

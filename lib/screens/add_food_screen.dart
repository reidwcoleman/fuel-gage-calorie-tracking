import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../data/food_database.dart';
import '../models/food_entry.dart';
import '../models/food_item.dart';
import '../providers/calorie_provider.dart';
import '../services/usda_food_service.dart';
import '../theme/app_theme.dart';
// MealType removed - foods are now logged throughout the day without categories

class AddFoodScreen extends StatefulWidget {
  const AddFoodScreen({super.key});

  @override
  State<AddFoodScreen> createState() => _AddFoodScreenState();
}

class _AddFoodScreenState extends State<AddFoodScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _customNameController = TextEditingController();
  final TextEditingController _customCaloriesController = TextEditingController();

  late TabController _tabController;
  String _searchQuery = '';
  String? _selectedCategory;
  bool _isSearchingUSDA = false;
  List<USDAFoodItem> _usdaResults = [];
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _customNameController.dispose();
    _customCaloriesController.dispose();
    _tabController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    setState(() => _searchQuery = query);

    // Debounce USDA API calls
    _debounceTimer?.cancel();
    if (query.length >= 2) {
      _debounceTimer = Timer(const Duration(milliseconds: 500), () {
        _searchUSDA(query);
      });
    } else {
      setState(() {
        _usdaResults = [];
        _isSearchingUSDA = false;
      });
    }
  }

  Future<void> _searchUSDA(String query) async {
    setState(() => _isSearchingUSDA = true);

    final results = await USDAFoodService.searchFoods(query);

    if (mounted) {
      setState(() {
        _usdaResults = results;
        _isSearchingUSDA = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Food'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.primaryTeal,
          labelColor: AppTheme.primaryTeal,
          unselectedLabelColor: AppTheme.textSecondary,
          tabs: const [
            Tab(text: 'Common'),
            Tab(text: 'USDA Database'),
            Tab(text: 'Custom'),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search foods...',
                prefixIcon: const Icon(Icons.search, color: AppTheme.textMuted),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: AppTheme.textMuted),
                        onPressed: () {
                          _searchController.clear();
                          _onSearchChanged('');
                        },
                      )
                    : null,
              ),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildCommonFoodsTab(),
                _buildUSDATab(),
                _buildCustomEntryForm(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommonFoodsTab() {
    final filteredFoods = _getFilteredFoods();
    final categories = FoodDatabase.categories;

    return Column(
      children: [
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
                return _buildCategoryChip(category, _selectedCategory == category);
              },
            ),
          ),
          const SizedBox(height: 8),
        ],
        Expanded(
          child: filteredFoods.isEmpty
              ? _buildEmptyState('No common foods found')
              : ListView.builder(
                  itemCount: filteredFoods.length,
                  itemBuilder: (context, index) => _buildFoodTile(filteredFoods[index]),
                ),
        ),
      ],
    );
  }

  Widget _buildUSDATab() {
    if (_searchQuery.length < 2) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.manage_search, size: 64, color: AppTheme.textMuted.withValues(alpha: 0.5)),
            const SizedBox(height: 16),
            const Text(
              'Search the USDA Database',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
            ),
            const SizedBox(height: 8),
            const Text(
              'Type at least 2 characters to search\nthousands of real foods',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.textSecondary),
            ),
          ],
        ),
      );
    }

    if (_isSearchingUSDA) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppTheme.primaryTeal),
            SizedBox(height: 16),
            Text('Searching USDA database...', style: TextStyle(color: AppTheme.textSecondary)),
          ],
        ),
      );
    }

    if (_usdaResults.isEmpty) {
      return _buildEmptyState('No foods found in USDA database');
    }

    return ListView.builder(
      itemCount: _usdaResults.length,
      itemBuilder: (context, index) => _buildUSDAFoodTile(_usdaResults[index]),
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
        selectedColor: AppTheme.primaryTeal.withValues(alpha: 0.3),
        checkmarkColor: AppTheme.primaryTeal,
        labelStyle: TextStyle(
          color: isSelected ? AppTheme.primaryTeal : AppTheme.textSecondary,
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
          style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          food.servingSize ?? '100g',
          style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
        ),
        trailing: Text(
          '${food.caloriesPerServing ?? food.caloriesPer100g} cal',
          style: const TextStyle(color: AppTheme.primaryTeal, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        onTap: () => _showQuantityDialog(food),
      ),
    );
  }

  Widget _buildUSDAFoodTile(USDAFoodItem food) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        title: Text(
          food.displayName,
          style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w500),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Per 100g: P:${food.protein.round()}g  C:${food.carbs.round()}g  F:${food.fat.round()}g',
              style: const TextStyle(color: AppTheme.textMuted, fontSize: 11),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${food.calories.round()}',
              style: const TextStyle(color: AppTheme.primaryTeal, fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const Text(
              'cal/100g',
              style: TextStyle(color: AppTheme.textMuted, fontSize: 10),
            ),
          ],
        ),
        onTap: () => _showUSDAQuantityDialog(food),
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.search_off, size: 64, color: AppTheme.textMuted),
          const SizedBox(height: 16),
          Text(message, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 18)),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => _tabController.animateTo(2),
            child: const Text('Add custom entry'),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomEntryForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Quick Add',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
          ),
          const SizedBox(height: 8),
          const Text(
            'Enter a food name and calories to quickly log it.',
            style: TextStyle(color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _customNameController,
            decoration: const InputDecoration(labelText: 'Food name', hintText: 'e.g., Homemade soup'),
            textCapitalization: TextCapitalization.sentences,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _customCaloriesController,
            decoration: const InputDecoration(labelText: 'Calories', hintText: 'e.g., 250', suffixText: 'cal'),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: _addCustomEntry,
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 4),
              child: Text('Add Food', style: TextStyle(fontSize: 16)),
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
              title: Text(food.name, style: const TextStyle(color: AppTheme.textPrimary)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(food.servingSize ?? '100g serving', style: const TextStyle(color: AppTheme.textSecondary)),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: quantity > 0.5 ? () => setDialogState(() => quantity -= 0.5) : null,
                        icon: const Icon(Icons.remove_circle_outline),
                        iconSize: 32,
                        color: AppTheme.primaryTeal,
                      ),
                      const SizedBox(width: 16),
                      Text(
                        quantity.toString(),
                        style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                      ),
                      const SizedBox(width: 16),
                      IconButton(
                        onPressed: () => setDialogState(() => quantity += 0.5),
                        icon: const Icon(Icons.add_circle_outline),
                        iconSize: 32,
                        color: AppTheme.primaryTeal,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '$totalCalories calories',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppTheme.primaryTeal),
                  ),
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
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

  void _showUSDAQuantityDialog(USDAFoodItem food) {
    double grams = 100.0;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final totalCalories = (food.calories * grams / 100).round();
            final totalProtein = (food.protein * grams / 100).round();
            final totalCarbs = (food.carbs * grams / 100).round();
            final totalFat = (food.fat * grams / 100).round();

            return AlertDialog(
              backgroundColor: AppTheme.cardBackground,
              title: Text(
                food.displayName,
                style: const TextStyle(color: AppTheme.textPrimary, fontSize: 16),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Amount in grams', style: TextStyle(color: AppTheme.textSecondary)),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: grams > 25 ? () => setDialogState(() => grams -= 25) : null,
                        icon: const Icon(Icons.remove_circle_outline),
                        iconSize: 32,
                        color: AppTheme.primaryTeal,
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 80,
                        child: TextField(
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.number,
                          controller: TextEditingController(text: grams.round().toString()),
                          onChanged: (v) {
                            final val = double.tryParse(v);
                            if (val != null && val > 0) {
                              setDialogState(() => grams = val);
                            }
                          },
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                          decoration: const InputDecoration(
                            suffixText: 'g',
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () => setDialogState(() => grams += 25),
                        icon: const Icon(Icons.add_circle_outline),
                        iconSize: 32,
                        color: AppTheme.primaryTeal,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '$totalCalories calories',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.primaryTeal),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildMacroChip('P', totalProtein, Colors.blue),
                      _buildMacroChip('C', totalCarbs, Colors.orange),
                      _buildMacroChip('F', totalFat, Colors.purple),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                ElevatedButton(
                  onPressed: () {
                    final entry = FoodEntry(
                      foodName: food.displayName,
                      calories: totalCalories,
                      quantity: grams,
                      unit: 'g',
                    );
                    context.read<CalorieProvider>().addFoodEntry(entry);
                    Navigator.pop(context);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${food.description} added'),
                        backgroundColor: AppTheme.primaryTeal,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    );
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

  Widget _buildMacroChip(String label, int value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '$label: ${value}g',
        style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 12),
      ),
    );
  }

  void _addFoodEntry(FoodItem food, double quantity, int calories) {
    final entry = FoodEntry(
      foodName: food.name,
      calories: calories,
      quantity: quantity,
      unit: food.servingSize != null ? 'serving' : '100g',
    );

    context.read<CalorieProvider>().addFoodEntry(entry);
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${food.name} added'),
        backgroundColor: AppTheme.primaryTeal,
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
        const SnackBar(content: Text('Please enter a food name'), backgroundColor: AppTheme.dangerRed),
      );
      return;
    }

    if (caloriesText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter calories'), backgroundColor: AppTheme.dangerRed),
      );
      return;
    }

    final calories = int.tryParse(caloriesText) ?? 0;
    if (calories <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid calorie amount'), backgroundColor: AppTheme.dangerRed),
      );
      return;
    }

    final entry = FoodEntry(
      foodName: name,
      calories: calories,
      quantity: 1,
      unit: 'serving',
    );

    context.read<CalorieProvider>().addFoodEntry(entry);
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$name added'),
        backgroundColor: AppTheme.primaryTeal,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}

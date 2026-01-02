import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/calorie_provider.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _goalController;

  @override
  void initState() {
    super.initState();
    final goal = context.read<CalorieProvider>().calorieGoal;
    _goalController = TextEditingController(text: goal.toString());
  }

  @override
  void dispose() {
    _goalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSection(
            'Daily Calorie Goal',
            'Set your target daily calorie intake',
            _buildGoalSetting(),
          ),
          const SizedBox(height: 24),
          _buildSection(
            'Quick Goal Presets',
            'Common calorie goals based on activity level',
            _buildPresets(),
          ),
          const SizedBox(height: 24),
          _buildSection(
            'About',
            null,
            _buildAbout(),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, String? subtitle, Widget content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 14,
            ),
          ),
        ],
        const SizedBox(height: 16),
        content,
      ],
    );
  }

  Widget _buildGoalSetting() {
    return Consumer<CalorieProvider>(
      builder: (context, provider, child) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _goalController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(5),
                    ],
                    decoration: const InputDecoration(
                      labelText: 'Daily Goal',
                      suffixText: 'calories',
                      border: OutlineInputBorder(),
                    ),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () => _saveGoal(provider),
                  child: const Text('Save'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPresets() {
    final presets = [
      {'label': 'Weight Loss', 'calories': 1500, 'icon': Icons.trending_down},
      {'label': 'Moderate', 'calories': 2000, 'icon': Icons.balance},
      {'label': 'Maintenance', 'calories': 2500, 'icon': Icons.horizontal_rule},
      {'label': 'Weight Gain', 'calories': 3000, 'icon': Icons.trending_up},
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: presets.map((preset) {
        return _buildPresetChip(
          preset['label'] as String,
          preset['calories'] as int,
          preset['icon'] as IconData,
        );
      }).toList(),
    );
  }

  Widget _buildPresetChip(String label, int calories, IconData icon) {
    return Consumer<CalorieProvider>(
      builder: (context, provider, child) {
        final isSelected = provider.calorieGoal == calories;

        return ActionChip(
          avatar: Icon(
            icon,
            size: 18,
            color: isSelected ? AppTheme.primaryGreen : AppTheme.textSecondary,
          ),
          label: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? AppTheme.primaryGreen : AppTheme.textPrimary,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              Text(
                '$calories cal',
                style: TextStyle(
                  fontSize: 12,
                  color: isSelected ? AppTheme.primaryGreen : AppTheme.textMuted,
                ),
              ),
            ],
          ),
          backgroundColor: isSelected
              ? AppTheme.primaryGreen.withOpacity(0.2)
              : AppTheme.cardBackground,
          side: BorderSide(
            color: isSelected ? AppTheme.primaryGreen : AppTheme.surfaceLight,
          ),
          onPressed: () {
            _goalController.text = calories.toString();
            provider.setCalorieGoal(calories);
            _showSavedSnackbar();
          },
        );
      },
    );
  }

  Widget _buildAbout() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGreen.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.local_gas_station,
                    color: AppTheme.primaryGreen,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Fuel Gage',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    Text(
                      'Version 1.0.0',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Track your calories like fuel in a tank. Simple, intuitive calorie tracking to keep you energized throughout the day.',
              style: TextStyle(
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _saveGoal(CalorieProvider provider) {
    final goal = int.tryParse(_goalController.text);
    if (goal != null && goal > 0 && goal <= 10000) {
      provider.setCalorieGoal(goal);
      _showSavedSnackbar();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid goal (1-10000 calories)'),
          backgroundColor: AppTheme.dangerRed,
        ),
      );
    }
  }

  void _showSavedSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Calorie goal updated!'),
        backgroundColor: AppTheme.primaryGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}

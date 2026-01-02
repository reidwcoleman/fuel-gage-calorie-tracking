import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/food_entry.dart';
import '../providers/calorie_provider.dart';
import '../services/groq_food_service.dart';
import '../theme/app_theme.dart';

class ScanFoodScreen extends StatefulWidget {
  const ScanFoodScreen({super.key});

  @override
  State<ScanFoodScreen> createState() => _ScanFoodScreenState();
}

class _ScanFoodScreenState extends State<ScanFoodScreen> {
  final TextEditingController _descriptionController = TextEditingController();
  bool _isAnalyzing = false;
  List<ScannedFood> _scannedFoods = [];
  String? _errorMessage;
  Uint8List? _imageBytes;

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Food Scan'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!GroqFoodService.hasApiKey) ...[
              _buildApiKeyWarning(),
              const SizedBox(height: 24),
            ],
            _buildDescriptionInput(),
            const SizedBox(height: 16),
            _buildImageUploadSection(),
            const SizedBox(height: 24),
            if (_isAnalyzing) _buildLoadingState(),
            if (_errorMessage != null) _buildErrorState(),
            if (_scannedFoods.isNotEmpty) _buildResults(),
          ],
        ),
      ),
    );
  }

  Widget _buildApiKeyWarning() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.warningYellow.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.warningYellow.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber, color: AppTheme.warningYellow),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Groq API Key Required',
                  style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                ),
                const SizedBox(height: 4),
                Text(
                  'Add your Groq API key in Settings to enable AI food scanning.',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Describe Your Food',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
        ),
        const SizedBox(height: 8),
        const Text(
          'Tell the AI what you ate and it will estimate the nutrition.',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _descriptionController,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'e.g., "A bowl of chicken fried rice with vegetables and an egg on top"',
          ),
          textCapitalization: TextCapitalization.sentences,
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: GroqFoodService.hasApiKey && !_isAnalyzing ? _analyzeDescription : null,
          icon: const Icon(Icons.auto_awesome),
          label: const Text('Analyze with AI'),
        ),
      ],
    );
  }

  Widget _buildImageUploadSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 32),
        const Text(
          'Or Upload a Photo',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
        ),
        const SizedBox(height: 8),
        const Text(
          'Take a photo of your food for AI analysis.',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
        const SizedBox(height: 12),
        if (_imageBytes != null) ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.memory(
              _imageBytes!,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => setState(() => _imageBytes = null),
                  icon: const Icon(Icons.close),
                  label: const Text('Remove'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: GroqFoodService.hasApiKey && !_isAnalyzing ? _analyzeImage : null,
                  icon: const Icon(Icons.auto_awesome),
                  label: const Text('Analyze'),
                ),
              ),
            ],
          ),
        ] else ...[
          Container(
            height: 150,
            decoration: BoxDecoration(
              color: AppTheme.surfaceLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.textMuted.withValues(alpha: 0.3), style: BorderStyle.solid),
            ),
            child: InkWell(
              onTap: _pickImage,
              borderRadius: BorderRadius.circular(12),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add_a_photo, size: 48, color: AppTheme.textMuted),
                    SizedBox(height: 8),
                    Text('Tap to upload photo', style: TextStyle(color: AppTheme.textMuted)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildLoadingState() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: const Column(
        children: [
          CircularProgressIndicator(color: AppTheme.primaryGreen),
          SizedBox(height: 16),
          Text('Analyzing your food with AI...', style: TextStyle(color: AppTheme.textSecondary)),
          SizedBox(height: 8),
          Text('This may take a few seconds', style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.dangerRed.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppTheme.dangerRed),
          const SizedBox(width: 12),
          Expanded(
            child: Text(_errorMessage!, style: const TextStyle(color: AppTheme.dangerRed)),
          ),
        ],
      ),
    );
  }

  Widget _buildResults() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.check_circle, color: AppTheme.primaryGreen),
            const SizedBox(width: 8),
            const Text(
              'Foods Detected',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
            ),
            const Spacer(),
            Text(
              '${_scannedFoods.length} item${_scannedFoods.length > 1 ? 's' : ''}',
              style: const TextStyle(color: AppTheme.textSecondary),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ..._scannedFoods.map((food) => _buildFoodCard(food)),
      ],
    );
  }

  Widget _buildFoodCard(ScannedFood food) {
    final confidenceColor = food.confidence == 'high'
        ? AppTheme.primaryGreen
        : food.confidence == 'medium'
            ? AppTheme.warningYellow
            : AppTheme.dangerRed;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    food.name,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: confidenceColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    food.confidence.toUpperCase(),
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: confidenceColor),
                  ),
                ),
              ],
            ),
            if (food.servingSize != null) ...[
              const SizedBox(height: 4),
              Text(food.servingSize!, style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                _buildNutrientChip('${food.estimatedCalories}', 'cal', AppTheme.primaryGreen),
                const SizedBox(width: 8),
                if (food.protein != null) _buildNutrientChip('${food.protein}g', 'P', Colors.blue),
                const SizedBox(width: 8),
                if (food.carbs != null) _buildNutrientChip('${food.carbs}g', 'C', Colors.orange),
                const SizedBox(width: 8),
                if (food.fat != null) _buildNutrientChip('${food.fat}g', 'F', Colors.purple),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _addFood(food),
                child: const Text('Add to Log'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNutrientChip(String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 14)),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(color: color.withValues(alpha: 0.7), fontSize: 10)),
        ],
      ),
    );
  }

  void _pickImage() {
    // For web/mobile, we'd use image_picker package
    // For now, show a placeholder message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Image upload coming soon! Use text description for now.'),
        backgroundColor: AppTheme.accent,
      ),
    );
  }

  Future<void> _analyzeDescription() async {
    final description = _descriptionController.text.trim();
    if (description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please describe your food'), backgroundColor: AppTheme.dangerRed),
      );
      return;
    }

    setState(() {
      _isAnalyzing = true;
      _errorMessage = null;
      _scannedFoods = [];
    });

    try {
      final foods = await GroqFoodService.analyzeDescription(description);
      setState(() {
        _scannedFoods = foods;
        _isAnalyzing = false;
      });

      if (foods.isEmpty) {
        setState(() => _errorMessage = 'Could not identify any foods. Try a more detailed description.');
      }
    } catch (e) {
      setState(() {
        _isAnalyzing = false;
        _errorMessage = 'Error: ${e.toString()}';
      });
    }
  }

  Future<void> _analyzeImage() async {
    if (_imageBytes == null) return;

    setState(() {
      _isAnalyzing = true;
      _errorMessage = null;
      _scannedFoods = [];
    });

    try {
      final base64Image = base64Encode(_imageBytes!);
      final foods = await GroqFoodService.analyzeImage(base64Image);
      setState(() {
        _scannedFoods = foods;
        _isAnalyzing = false;
      });

      if (foods.isEmpty) {
        setState(() => _errorMessage = 'Could not identify any foods in the image.');
      }
    } catch (e) {
      setState(() {
        _isAnalyzing = false;
        _errorMessage = 'Error: ${e.toString()}';
      });
    }
  }

  void _addFood(ScannedFood food) {
    final entry = FoodEntry(
      foodName: food.name,
      calories: food.estimatedCalories,
      quantity: 1,
      unit: food.servingSize ?? 'serving',
    );

    context.read<CalorieProvider>().addFoodEntry(entry);
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${food.name} added (+${food.estimatedCalories} cal)'),
        backgroundColor: AppTheme.primaryGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}

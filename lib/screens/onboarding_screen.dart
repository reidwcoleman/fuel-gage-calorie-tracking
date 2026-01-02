import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/calorie_provider.dart';
import '../theme/app_theme.dart';
import 'main_shell.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _nameController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _continue() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your name'),
          backgroundColor: AppTheme.dangerRed,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    await context.read<CalorieProvider>().setUserName(name);

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainShell()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreen.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.local_gas_station,
                  size: 48,
                  color: AppTheme.primaryGreen,
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Welcome to\nFuel Gage',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Track your energy throughout the day',
                style: TextStyle(
                  fontSize: 16,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 48),
              const Text(
                'What should we call you?',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _nameController,
                autofocus: true,
                textCapitalization: TextCapitalization.words,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: 'Your name',
                  hintStyle: TextStyle(
                    color: AppTheme.textMuted.withValues(alpha: 0.5),
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                ),
                onSubmitted: (_) => _continue(),
              ),
              Container(
                height: 2,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primaryGreen,
                      AppTheme.primaryGreen.withValues(alpha: 0.3),
                    ],
                  ),
                ),
              ),
              const Spacer(flex: 2),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _continue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Get Started',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

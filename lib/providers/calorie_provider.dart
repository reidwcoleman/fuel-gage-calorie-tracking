import 'package:flutter/foundation.dart';
import '../models/daily_log.dart';
import '../models/food_entry.dart';
import '../services/energy_service.dart';
import '../services/supabase_service.dart';

class CalorieProvider extends ChangeNotifier {
  final EnergyService _energyService;

  DateTime _selectedDate = DateTime.now();
  DailyLog? _currentLog;
  int _calorieGoal = 2000;
  bool _isLoading = true;
  String _userName = '';

  // Energy tracking (percentage-based)
  double _currentEnergy = 50.0;
  double _energyLostSinceLastLogin = 0.0;
  String _lastActiveDescription = '';
  bool _showEnergyLostBanner = false;

  CalorieProvider(this._energyService);

  DateTime get selectedDate => _selectedDate;
  DailyLog get currentLog => _currentLog ?? DailyLog(date: _selectedDate);
  int get calorieGoal => _calorieGoal;
  bool get isLoading => _isLoading;
  String get userName => _userName;

  // Energy getters (percentage-based)
  double get currentEnergy => _currentEnergy;
  double get energyLostSinceLastLogin => _energyLostSinceLastLogin;
  String get lastActiveDescription => _lastActiveDescription;
  bool get showEnergyLostBanner => _showEnergyLostBanner;

  int get totalCalories => currentLog.totalCalories;
  int get remainingCalories => _calorieGoal - totalCalories;

  /// Progress percentage (0.0 to 1.0+)
  double get progressPercent => (_currentEnergy / 100).clamp(-0.25, 1.5);

  /// Fuel status based on energy percentage
  String get fuelStatus => _energyService.getFuelStatus(_currentEnergy);

  /// Decay rate per hour
  double get decayRatePerHour => EnergyService.percentPerHour;

  /// Get greeting based on time of day
  String get greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  Future<void> init() async {
    // Load user data from Supabase
    _userName = SupabaseService.currentUserName ?? '';
    _calorieGoal = await SupabaseService.getCalorieGoal();

    await _loadLogForDate(_selectedDate);
    await _processEnergyDecay();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _processEnergyDecay() async {
    final lastActive = _energyService.getLastActiveTime();
    _lastActiveDescription = _energyService.getTimeDescription(lastActive);

    // Calculate and apply energy decay
    _energyLostSinceLastLogin = await _energyService.processEnergyDecay();
    _currentEnergy = _energyService.getCurrentEnergy();

    // Show banner if significant energy was lost (more than 5%)
    _showEnergyLostBanner = _energyLostSinceLastLogin > 5.0;
  }

  void dismissEnergyLostBanner() {
    _showEnergyLostBanner = false;
    notifyListeners();
  }

  Future<void> _loadLogForDate(DateTime date) async {
    final entries = await SupabaseService.getFoodEntries(date);
    _currentLog = DailyLog(
      date: DateTime(date.year, date.month, date.day),
      entries: entries,
    );
  }

  Future<void> selectDate(DateTime date) async {
    _selectedDate = date;
    await _loadLogForDate(date);
    notifyListeners();
  }

  Future<void> addFoodEntry(FoodEntry entry) async {
    final savedEntry = await SupabaseService.addFoodEntry(_selectedDate, entry);
    if (savedEntry != null) {
      await _loadLogForDate(_selectedDate);

      // Add energy as percentage of daily goal
      await _energyService.addEnergy(entry.calories, _calorieGoal);
      _currentEnergy = _energyService.getCurrentEnergy();

      notifyListeners();
    }
  }

  Future<void> removeFoodEntry(String entryId) async {
    // Find the entry to get its calories before removing
    final entry = currentLog.entries.firstWhere(
      (e) => e.id == entryId,
      orElse: () => FoodEntry(foodName: '', calories: 0, mealType: MealType.snack),
    );

    final success = await SupabaseService.removeFoodEntry(entryId);
    if (success) {
      await _loadLogForDate(_selectedDate);

      // Remove energy when food is deleted
      if (entry.calories > 0) {
        await _energyService.removeEnergy(entry.calories, _calorieGoal);
        _currentEnergy = _energyService.getCurrentEnergy();
      }

      notifyListeners();
    }
  }

  Future<void> setCalorieGoal(int goal) async {
    _calorieGoal = goal;
    await SupabaseService.setCalorieGoal(goal);
    notifyListeners();
  }

  Future<void> setUserName(String name) async {
    _userName = name;
    await SupabaseService.updateUserName(name);
    notifyListeners();
  }

  Future<Map<String, DailyLog>> getAllLogs() async {
    return await SupabaseService.getAllLogs();
  }

  void goToPreviousDay() {
    selectDate(_selectedDate.subtract(const Duration(days: 1)));
  }

  void goToNextDay() {
    final tomorrow = _selectedDate.add(const Duration(days: 1));
    final now = DateTime.now();
    if (tomorrow.isBefore(now) || _isSameDay(tomorrow, now)) {
      selectDate(tomorrow);
    }
  }

  void goToToday() {
    selectDate(DateTime.now());
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  bool get isToday => _isSameDay(_selectedDate, DateTime.now());

  /// Manually refresh energy
  Future<void> refreshEnergy() async {
    _currentEnergy = _energyService.getCurrentEnergy();
    await _energyService.updateLastActiveTime();
    notifyListeners();
  }
}

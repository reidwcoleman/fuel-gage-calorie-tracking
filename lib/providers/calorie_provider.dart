import 'package:flutter/foundation.dart';
import '../models/daily_log.dart';
import '../models/food_entry.dart';
import '../services/energy_service.dart';
import '../services/storage_service.dart';

class CalorieProvider extends ChangeNotifier {
  final StorageService _storage;
  final EnergyService _energyService;

  DateTime _selectedDate = DateTime.now();
  DailyLog? _currentLog;
  int _calorieGoal = 2000;
  bool _isLoading = true;

  // Energy tracking
  int _currentEnergy = 0;
  int _energyLostSinceLastLogin = 0;
  String _lastActiveDescription = '';
  bool _showEnergyLostBanner = false;

  CalorieProvider(this._storage, this._energyService);

  DateTime get selectedDate => _selectedDate;
  DailyLog get currentLog => _currentLog ?? DailyLog(date: _selectedDate);
  int get calorieGoal => _calorieGoal;
  bool get isLoading => _isLoading;

  // Energy getters
  int get currentEnergy => _currentEnergy;
  int get energyLostSinceLastLogin => _energyLostSinceLastLogin;
  String get lastActiveDescription => _lastActiveDescription;
  bool get showEnergyLostBanner => _showEnergyLostBanner;

  int get totalCalories => currentLog.totalCalories;
  int get remainingCalories => _calorieGoal - totalCalories;

  /// Progress based on current energy vs goal
  double get progressPercent => (_currentEnergy / _calorieGoal).clamp(-0.25, 1.5);

  /// Energy-based fuel status
  String get fuelStatus {
    if (_currentEnergy < 0) return 'Energy Deficit!';
    final percent = progressPercent;
    if (percent < 0.25) return 'Running on Empty';
    if (percent < 0.5) return 'Low Fuel';
    if (percent < 0.75) return 'Half Tank';
    if (percent <= 1.0) return 'Almost Full';
    return 'Tank Overflowing!';
  }

  /// Hourly burn rate (for display)
  int get hourlyBurnRate => EnergyService.caloriesPerHour;

  Future<void> init() async {
    _calorieGoal = _storage.getCalorieGoal();
    await _loadLogForDate(_selectedDate);

    // Process energy decay since last login
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

    // Show banner if significant energy was lost (more than 15 minutes worth)
    _showEnergyLostBanner = _energyLostSinceLastLogin > (EnergyService.caloriesPerHour / 4);
  }

  void dismissEnergyLostBanner() {
    _showEnergyLostBanner = false;
    notifyListeners();
  }

  Future<void> _loadLogForDate(DateTime date) async {
    _currentLog = _storage.getLogForDate(date);
    _currentLog ??= DailyLog(date: DateTime(date.year, date.month, date.day));
  }

  Future<void> selectDate(DateTime date) async {
    _selectedDate = date;
    await _loadLogForDate(date);
    notifyListeners();
  }

  Future<void> addFoodEntry(FoodEntry entry) async {
    await _storage.addEntry(_selectedDate, entry);
    await _loadLogForDate(_selectedDate);

    // Add energy when food is logged
    await _energyService.addEnergy(entry.calories);
    _currentEnergy = _energyService.getCurrentEnergy();

    notifyListeners();
  }

  Future<void> removeFoodEntry(String entryId) async {
    // Find the entry to get its calories before removing
    final entry = currentLog.entries.firstWhere(
      (e) => e.id == entryId,
      orElse: () => FoodEntry(foodName: '', calories: 0, mealType: MealType.snack),
    );

    await _storage.removeEntry(_selectedDate, entryId);
    await _loadLogForDate(_selectedDate);

    // Remove energy when food is deleted
    if (entry.calories > 0) {
      await _energyService.addEnergy(-entry.calories);
      _currentEnergy = _energyService.getCurrentEnergy();
    }

    notifyListeners();
  }

  Future<void> setCalorieGoal(int goal) async {
    _calorieGoal = goal;
    await _storage.setCalorieGoal(goal);
    notifyListeners();
  }

  Map<String, DailyLog> getAllLogs() {
    return _storage.getAllLogs();
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

  /// Manually refresh energy (call periodically while app is open)
  Future<void> refreshEnergy() async {
    _currentEnergy = _energyService.getCurrentEnergy();
    await _energyService.updateLastActiveTime();
    notifyListeners();
  }

  /// Get energy message
  String get energyMessage => _energyService.getEnergyMessage(_currentEnergy, _calorieGoal);
}

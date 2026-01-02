import 'package:flutter/foundation.dart';
import '../models/daily_log.dart';
import '../models/food_entry.dart';
import '../services/storage_service.dart';

class CalorieProvider extends ChangeNotifier {
  final StorageService _storage;

  DateTime _selectedDate = DateTime.now();
  DailyLog? _currentLog;
  int _calorieGoal = 2000;
  bool _isLoading = true;

  CalorieProvider(this._storage);

  DateTime get selectedDate => _selectedDate;
  DailyLog get currentLog => _currentLog ?? DailyLog(date: _selectedDate);
  int get calorieGoal => _calorieGoal;
  bool get isLoading => _isLoading;

  int get totalCalories => currentLog.totalCalories;
  int get remainingCalories => _calorieGoal - totalCalories;
  double get progressPercent => (totalCalories / _calorieGoal).clamp(0.0, 1.5);

  String get fuelStatus {
    final percent = progressPercent;
    if (percent < 0.25) return 'Running on Empty';
    if (percent < 0.5) return 'Low Fuel';
    if (percent < 0.75) return 'Half Tank';
    if (percent <= 1.0) return 'Almost Full';
    return 'Tank Overflowing!';
  }

  Future<void> init() async {
    _calorieGoal = _storage.getCalorieGoal();
    await _loadLogForDate(_selectedDate);
    _isLoading = false;
    notifyListeners();
  }

  Future<void> _loadLogForDate(DateTime date) async {
    _currentLog = _storage.getLogForDate(date);
    if (_currentLog == null) {
      _currentLog = DailyLog(date: DateTime(date.year, date.month, date.day));
    }
  }

  Future<void> selectDate(DateTime date) async {
    _selectedDate = date;
    await _loadLogForDate(date);
    notifyListeners();
  }

  Future<void> addFoodEntry(FoodEntry entry) async {
    await _storage.addEntry(_selectedDate, entry);
    await _loadLogForDate(_selectedDate);
    notifyListeners();
  }

  Future<void> removeFoodEntry(String entryId) async {
    await _storage.removeEntry(_selectedDate, entryId);
    await _loadLogForDate(_selectedDate);
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
}

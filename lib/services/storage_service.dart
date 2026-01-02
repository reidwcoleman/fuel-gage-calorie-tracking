import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/daily_log.dart';
import '../models/food_entry.dart';

class StorageService {
  static const String _logsKey = 'daily_logs';
  static const String _goalKey = 'calorie_goal';
  static const String _customFoodsKey = 'custom_foods';
  static const String _groqApiKeyKey = 'groq_api_key';
  static const String _deviceIdKey = 'device_id';

  late SharedPreferences _prefs;
  static StorageService? _instance;

  static Future<StorageService> getInstance() async {
    if (_instance == null) {
      _instance = StorageService();
      await _instance!.init();
    }
    return _instance!;
  }

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Calorie Goal
  int getCalorieGoal() {
    return _prefs.getInt(_goalKey) ?? 2000;
  }

  Future<void> setCalorieGoal(int goal) async {
    await _prefs.setInt(_goalKey, goal);
  }

  // Daily Logs
  Map<String, DailyLog> getAllLogs() {
    final String? logsJson = _prefs.getString(_logsKey);
    if (logsJson == null) return {};

    final Map<String, dynamic> decoded = jsonDecode(logsJson);
    return decoded.map(
      (key, value) => MapEntry(key, DailyLog.fromJson(value)),
    );
  }

  DailyLog? getLogForDate(DateTime date) {
    final logs = getAllLogs();
    final key = _dateKey(date);
    return logs[key];
  }

  Future<void> saveLog(DailyLog log) async {
    final logs = getAllLogs();
    logs[log.dateKey] = log;
    await _saveLogs(logs);
  }

  Future<void> addEntry(DateTime date, FoodEntry entry) async {
    final logs = getAllLogs();
    final key = _dateKey(date);

    DailyLog log = logs[key] ?? DailyLog(date: _normalizeDate(date));
    log = log.addEntry(entry);
    logs[key] = log;

    await _saveLogs(logs);
  }

  Future<void> removeEntry(DateTime date, String entryId) async {
    final logs = getAllLogs();
    final key = _dateKey(date);

    if (logs.containsKey(key)) {
      logs[key] = logs[key]!.removeEntry(entryId);
      await _saveLogs(logs);
    }
  }

  Future<void> _saveLogs(Map<String, DailyLog> logs) async {
    final encoded = logs.map((key, value) => MapEntry(key, value.toJson()));
    await _prefs.setString(_logsKey, jsonEncode(encoded));
  }

  String _dateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  // Custom Foods
  List<Map<String, dynamic>> getCustomFoods() {
    final String? foodsJson = _prefs.getString(_customFoodsKey);
    if (foodsJson == null) return [];
    return List<Map<String, dynamic>>.from(jsonDecode(foodsJson));
  }

  Future<void> saveCustomFood(Map<String, dynamic> food) async {
    final foods = getCustomFoods();
    foods.add(food);
    await _prefs.setString(_customFoodsKey, jsonEncode(foods));
  }

  // Groq API Key
  String? getGroqApiKey() {
    return _prefs.getString(_groqApiKeyKey);
  }

  Future<void> setGroqApiKey(String? key) async {
    if (key == null || key.isEmpty) {
      await _prefs.remove(_groqApiKeyKey);
    } else {
      await _prefs.setString(_groqApiKeyKey, key);
    }
  }

  // Device ID - persists across app launches
  String getOrCreateDeviceId() {
    String? deviceId = _prefs.getString(_deviceIdKey);
    if (deviceId == null) {
      deviceId = 'device_${DateTime.now().millisecondsSinceEpoch}';
      _prefs.setString(_deviceIdKey, deviceId);
    }
    return deviceId;
  }
}

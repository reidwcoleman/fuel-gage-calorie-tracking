import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/food_entry.dart';
import '../models/daily_log.dart';

class SupabaseService {
  static const String _supabaseUrl = 'https://tbrmbourxbpzyohfpuqg.supabase.co';
  static const String _supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRicm1ib3VyeGJwenlvaGZwdXFnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjczMjAwNjcsImV4cCI6MjA4Mjg5NjA2N30.OVpLm1wK8oJFPJqwSPgL3ujwRZ9DJ02I8eMsvrOukr0';

  static SupabaseClient? _client;
  static String? _currentUserId;
  static String? _currentUserName;

  static Future<void> init() async {
    await Supabase.initialize(
      url: _supabaseUrl,
      anonKey: _supabaseAnonKey,
    );
    _client = Supabase.instance.client;
    // No auth needed - using anon key with RLS disabled or public policies
  }

  static SupabaseClient get client {
    if (_client == null) {
      throw Exception('Supabase not initialized. Call SupabaseService.init() first.');
    }
    return _client!;
  }

  static String? get currentUserId => _currentUserId;
  static String? get currentUserName => _currentUserName;

  /// Fetch the Groq API key from the app_config table
  static Future<String?> getGroqApiKey() async {
    try {
      final response = await client
          .from('app_config')
          .select('value')
          .eq('key', 'groq_api_key')
          .single();

      return response['value'] as String?;
    } catch (e) {
      print('Error fetching Groq API key: $e');
      return null;
    }
  }

  /// Get or create a user profile by device ID
  static Future<Map<String, dynamic>?> getOrCreateUser(String deviceId) async {
    try {
      // Try to find existing user
      final existing = await client
          .from('users')
          .select()
          .eq('device_id', deviceId)
          .maybeSingle();

      if (existing != null) {
        _currentUserId = existing['id'] as String;
        _currentUserName = existing['name'] as String?;
        return existing;
      }

      // Create new user
      final newUser = await client
          .from('users')
          .insert({'device_id': deviceId})
          .select()
          .single();

      _currentUserId = newUser['id'] as String;
      _currentUserName = newUser['name'] as String?;
      return newUser;
    } catch (e) {
      print('Error getting/creating user: $e');
      return null;
    }
  }

  /// Update user's name
  static Future<bool> updateUserName(String name) async {
    if (_currentUserId == null) return false;

    try {
      await client
          .from('users')
          .update({'name': name})
          .eq('id', _currentUserId!);

      _currentUserName = name;
      return true;
    } catch (e) {
      print('Error updating user name: $e');
      return false;
    }
  }

  /// Get user's calorie goal
  static Future<int> getCalorieGoal() async {
    if (_currentUserId == null) return 2000;

    try {
      final response = await client
          .from('users')
          .select('calorie_goal')
          .eq('id', _currentUserId!)
          .single();

      return response['calorie_goal'] as int? ?? 2000;
    } catch (e) {
      return 2000;
    }
  }

  /// Update user's calorie goal
  static Future<bool> setCalorieGoal(int goal) async {
    if (_currentUserId == null) return false;

    try {
      await client
          .from('users')
          .update({'calorie_goal': goal})
          .eq('id', _currentUserId!);
      return true;
    } catch (e) {
      print('Error setting calorie goal: $e');
      return false;
    }
  }

  /// Get food entries for a specific date
  static Future<List<FoodEntry>> getFoodEntries(DateTime date) async {
    if (_currentUserId == null) return [];

    final dateKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

    try {
      final response = await client
          .from('food_entries')
          .select()
          .eq('user_id', _currentUserId!)
          .eq('date', dateKey)
          .order('created_at', ascending: true);

      return (response as List).map((e) => FoodEntry(
        id: e['id'] as String,
        foodName: e['food_name'] as String,
        calories: e['calories'] as int,
        quantity: (e['quantity'] as num?)?.toDouble() ?? 1.0,
        unit: e['unit'] as String? ?? 'serving',
      )).toList();
    } catch (e) {
      print('Error getting food entries: $e');
      return [];
    }
  }

  /// Add a food entry
  static Future<FoodEntry?> addFoodEntry(DateTime date, FoodEntry entry) async {
    if (_currentUserId == null) return null;

    final dateKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

    try {
      final response = await client
          .from('food_entries')
          .insert({
            'user_id': _currentUserId,
            'date': dateKey,
            'food_name': entry.foodName,
            'calories': entry.calories,
            'quantity': entry.quantity,
            'unit': entry.unit,
          })
          .select()
          .single();

      return FoodEntry(
        id: response['id'] as String,
        foodName: response['food_name'] as String,
        calories: response['calories'] as int,
        quantity: (response['quantity'] as num?)?.toDouble() ?? 1.0,
        unit: response['unit'] as String? ?? 'serving',
      );
    } catch (e) {
      print('Error adding food entry: $e');
      return null;
    }
  }

  /// Remove a food entry
  static Future<bool> removeFoodEntry(String entryId) async {
    try {
      await client
          .from('food_entries')
          .delete()
          .eq('id', entryId);
      return true;
    } catch (e) {
      print('Error removing food entry: $e');
      return false;
    }
  }

  /// Get all food logs for history
  static Future<Map<String, DailyLog>> getAllLogs() async {
    if (_currentUserId == null) return {};

    try {
      final response = await client
          .from('food_entries')
          .select()
          .eq('user_id', _currentUserId!)
          .order('date', ascending: false);

      final Map<String, List<FoodEntry>> entriesByDate = {};

      for (final e in response) {
        final dateKey = e['date'] as String;
        final entry = FoodEntry(
          id: e['id'] as String,
          foodName: e['food_name'] as String,
          calories: e['calories'] as int,
          quantity: (e['quantity'] as num?)?.toDouble() ?? 1.0,
          unit: e['unit'] as String? ?? 'serving',
        );

        entriesByDate.putIfAbsent(dateKey, () => []);
        entriesByDate[dateKey]!.add(entry);
      }

      final Map<String, DailyLog> logs = {};
      for (final entry in entriesByDate.entries) {
        final parts = entry.key.split('-');
        final date = DateTime(
          int.parse(parts[0]),
          int.parse(parts[1]),
          int.parse(parts[2]),
        );
        logs[entry.key] = DailyLog(date: date, entries: entry.value);
      }

      return logs;
    } catch (e) {
      print('Error getting all logs: $e');
      return {};
    }
  }

  /// Sign out the current user
  static Future<void> signOut() async {
    try {
      await client.auth.signOut();
      _currentUserId = null;
      _currentUserName = null;
    } catch (e) {
      print('Error signing out: $e');
    }
  }
}

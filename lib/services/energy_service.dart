import 'package:shared_preferences/shared_preferences.dart';

/// Service to manage energy decay over time
///
/// Energy decreases at ~4.17% per hour (100% / 24 hours)
/// This simulates the body using energy throughout the day
class EnergyService {
  static const String _lastActiveKey = 'last_active_time';
  static const String _currentEnergyKey = 'current_energy_percent';
  static const String _dailyEnergyResetKey = 'daily_energy_reset';

  /// Percentage of energy lost per hour (100% / ~16 waking hours ≈ 6.25%)
  static const double percentPerHour = 6.25;

  /// Minimum energy level percentage
  static const double minimumEnergy = -25.0;

  /// Maximum energy level percentage
  static const double maximumEnergy = 150.0;

  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// Get the last time the app was active
  DateTime? getLastActiveTime() {
    final timestamp = _prefs.getInt(_lastActiveKey);
    if (timestamp == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(timestamp);
  }

  /// Update the last active time to now
  Future<void> updateLastActiveTime() async {
    await _prefs.setInt(_lastActiveKey, DateTime.now().millisecondsSinceEpoch);
  }

  /// Get the current energy level as percentage (0-100+)
  double getCurrentEnergy() {
    return _prefs.getDouble(_currentEnergyKey) ?? 50.0;
  }

  /// Set the current energy level percentage
  Future<void> setCurrentEnergy(double percent) async {
    await _prefs.setDouble(_currentEnergyKey, percent.clamp(minimumEnergy, maximumEnergy));
  }

  /// Add energy based on calories eaten and daily goal
  /// Converts calories to percentage of daily goal
  Future<void> addEnergy(int calories, int dailyGoal) async {
    final current = getCurrentEnergy();
    final percentToAdd = (calories / dailyGoal) * 100;
    await setCurrentEnergy(current + percentToAdd);
  }

  /// Remove energy based on calories removed and daily goal
  Future<void> removeEnergy(int calories, int dailyGoal) async {
    final current = getCurrentEnergy();
    final percentToRemove = (calories / dailyGoal) * 100;
    await setCurrentEnergy(current - percentToRemove);
  }

  /// Calculate energy percentage lost since last active time
  double calculateEnergyLost(DateTime? lastActive) {
    if (lastActive == null) return 0;

    final now = DateTime.now();
    final difference = now.difference(lastActive);

    // Calculate hours elapsed (with decimals for partial hours)
    final hoursElapsed = difference.inMinutes / 60.0;

    // Calculate percentage lost
    final percentLost = hoursElapsed * percentPerHour;

    return percentLost;
  }

  /// Process energy decay since last session
  /// Returns the percentage of energy lost
  Future<double> processEnergyDecay() async {
    final lastActive = getLastActiveTime();

    if (lastActive == null) {
      // First time opening app - start at 50%
      await setCurrentEnergy(50.0);
      await updateLastActiveTime();
      return 0;
    }

    // Check if it's a new day - reset tracking
    final now = DateTime.now();
    final lastResetDay = _prefs.getString(_dailyEnergyResetKey);
    final todayKey = '${now.year}-${now.month}-${now.day}';

    if (lastResetDay != todayKey) {
      // New day - don't carry over yesterday's deficit too harshly
      await _prefs.setString(_dailyEnergyResetKey, todayKey);
      final currentEnergy = getCurrentEnergy();
      if (currentEnergy < 0) {
        // Reset negative energy to 0 at start of new day
        await setCurrentEnergy(0);
      }
    }

    // Calculate time since last active
    final percentLost = calculateEnergyLost(lastActive);

    if (percentLost > 0) {
      // Apply energy decay
      final current = getCurrentEnergy();
      await setCurrentEnergy(current - percentLost);
    }

    // Update last active time
    await updateLastActiveTime();

    return percentLost;
  }

  /// Get a human-readable description of time elapsed
  String getTimeDescription(DateTime? lastActive) {
    if (lastActive == null) return '';

    final now = DateTime.now();
    final difference = now.difference(lastActive);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} min ago';
    }
    return 'just now';
  }

  /// Get the fuel status text based on energy percentage
  String getFuelStatus(double percent) {
    if (percent < 0) return 'Empty';
    if (percent < 15) return 'Critical';
    if (percent < 30) return 'Low';
    if (percent < 50) return 'Half';
    if (percent < 75) return 'Good';
    if (percent <= 100) return 'Full';
    return 'Overflow';
  }
}

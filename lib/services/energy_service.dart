import 'package:shared_preferences/shared_preferences.dart';

/// Service to manage energy decay over time
///
/// Energy decreases at 75 calories/hour (based on ~1800 cal/day BMR)
/// This simulates the body burning energy throughout the day
class EnergyService {
  static const String _lastActiveKey = 'last_active_time';
  static const String _currentEnergyKey = 'current_energy';
  static const String _dailyEnergyResetKey = 'daily_energy_reset';

  /// Calories burned per hour (average BMR / 24)
  /// Average BMR is ~1800 cal/day = 75 cal/hour
  static const int caloriesPerHour = 75;

  /// Minimum energy level (prevents going too negative)
  static const int minimumEnergy = -500;

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

  /// Get the current energy level
  int getCurrentEnergy() {
    return _prefs.getInt(_currentEnergyKey) ?? 0;
  }

  /// Set the current energy level
  Future<void> setCurrentEnergy(int energy) async {
    await _prefs.setInt(_currentEnergyKey, energy.clamp(minimumEnergy, 10000));
  }

  /// Add energy (when eating food)
  Future<void> addEnergy(int calories) async {
    final current = getCurrentEnergy();
    await setCurrentEnergy(current + calories);
  }

  /// Calculate energy lost since last active time
  /// Returns the amount of energy lost (positive number)
  int calculateEnergyLost(DateTime? lastActive) {
    if (lastActive == null) return 0;

    final now = DateTime.now();
    final difference = now.difference(lastActive);

    // Calculate hours elapsed (with decimals for partial hours)
    final hoursElapsed = difference.inMinutes / 60.0;

    // Calculate energy lost
    final energyLost = (hoursElapsed * caloriesPerHour).round();

    return energyLost;
  }

  /// Process energy decay since last session
  /// Returns the amount of energy lost
  Future<int> processEnergyDecay() async {
    final lastActive = getLastActiveTime();

    if (lastActive == null) {
      // First time opening app
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
    final energyLost = calculateEnergyLost(lastActive);

    if (energyLost > 0) {
      // Apply energy decay
      final current = getCurrentEnergy();
      await setCurrentEnergy(current - energyLost);
    }

    // Update last active time
    await updateLastActiveTime();

    return energyLost;
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
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    }
    return 'just now';
  }

  /// Get motivational message based on energy level
  String getEnergyMessage(int energy, int goal) {
    final percent = energy / goal;

    if (energy < 0) {
      return 'Energy deficit! Time to refuel!';
    } else if (percent < 0.25) {
      return 'Running low - grab a snack!';
    } else if (percent < 0.5) {
      return 'Could use some fuel soon';
    } else if (percent < 0.75) {
      return 'Energy levels looking good!';
    } else if (percent <= 1.0) {
      return 'Tank is nearly full!';
    } else {
      return 'Fully fueled and ready to go!';
    }
  }
}

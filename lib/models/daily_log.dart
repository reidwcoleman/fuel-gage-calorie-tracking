import 'food_entry.dart';

class DailyLog {
  final DateTime date;
  final List<FoodEntry> entries;

  DailyLog({
    required this.date,
    List<FoodEntry>? entries,
  }) : entries = entries ?? [];

  int get totalCalories => entries.fold(0, (sum, entry) => sum + entry.calories);

  String get dateKey =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'entries': entries.map((e) => e.toJson()).toList(),
      };

  factory DailyLog.fromJson(Map<String, dynamic> json) => DailyLog(
        date: DateTime.parse(json['date']),
        entries: (json['entries'] as List)
            .map((e) => FoodEntry.fromJson(e))
            .toList(),
      );

  DailyLog copyWith({
    DateTime? date,
    List<FoodEntry>? entries,
  }) {
    return DailyLog(
      date: date ?? this.date,
      entries: entries ?? List.from(this.entries),
    );
  }

  DailyLog addEntry(FoodEntry entry) {
    return copyWith(entries: [...entries, entry]);
  }

  DailyLog removeEntry(String entryId) {
    return copyWith(
      entries: entries.where((e) => e.id != entryId).toList(),
    );
  }
}

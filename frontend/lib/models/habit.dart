import 'dart:math';

import '../utils/date_utils.dart';

class Habit {
  const Habit({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.dailyTarget,
    required this.createdAt,
    this.completionDates = const <String>{},
    this.dailyProgress = const <String, int>{},
    this.color = 'emerald',
    this.icon = 'track_changes',
  });

  final String id;
  final String title;
  final String description;
  final String category;
  final int dailyTarget;
  final DateTime createdAt;
  final Set<String> completionDates;
  final Map<String, int> dailyProgress;
  final String color;
  final String icon;

  Habit copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    int? dailyTarget,
    DateTime? createdAt,
    Set<String>? completionDates,
    Map<String, int>? dailyProgress,
    String? color,
    String? icon,
  }) {
    return Habit(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      dailyTarget: dailyTarget ?? this.dailyTarget,
      createdAt: createdAt ?? this.createdAt,
      completionDates: completionDates ?? this.completionDates,
      dailyProgress: dailyProgress ?? this.dailyProgress,
      color: color ?? this.color,
      icon: icon ?? this.icon,
    );
  }

  bool isCompletedOn(DateTime date) {
    return completionDates.contains(dateKey(date));
  }

  Habit toggleForDate(DateTime date) {
    final updatedDates = <String>{...completionDates};
    final updatedProgress = <String, int>{...dailyProgress};
    final key = dateKey(date);
    if (updatedDates.contains(key)) {
      updatedDates.remove(key);
      updatedProgress[key] = 0;
    } else {
      updatedDates.add(key);
      updatedProgress[key] = dailyTarget;
    }
    return copyWith(
      completionDates: updatedDates,
      dailyProgress: updatedProgress,
    );
  }

  Habit markCompletedForDate(DateTime date) {
    final updatedDates = <String>{...completionDates, dateKey(date)};
    final updatedProgress = <String, int>{...dailyProgress, dateKey(date): dailyTarget};
    return copyWith(
      completionDates: updatedDates,
      dailyProgress: updatedProgress,
    );
  }

  int getProgressForDate(DateTime date) {
    final key = dateKey(date);
    return dailyProgress[key] ?? (isCompletedOn(date) ? dailyTarget : 0);
  }

  double getCompletionRatioForDate(DateTime date) {
    if (dailyTarget <= 0) return 0.0;
    return getProgressForDate(date) / dailyTarget;
  }

  int completionCountInLastDays(int days, {DateTime? referenceDate}) {
    final reference = dateOnly(referenceDate ?? DateTime.now());
    final start = reference.subtract(Duration(days: days - 1));

    var count = 0;
    for (final completion in completionDates) {
      final completionDate = parseDateKey(completion);
      if (!completionDate.isBefore(start) && !completionDate.isAfter(reference)) {
        count++;
      }
    }
    return count;
  }

  double weeklyCompletionRatio({DateTime? referenceDate}) {
    return completionCountInLastDays(7, referenceDate: referenceDate) / 7;
  }

  double lifetimeCompletionRatio({DateTime? referenceDate}) {
    final reference = dateOnly(referenceDate ?? DateTime.now());
    final created = dateOnly(createdAt);
    final daysSinceCreated = max(1, reference.difference(created).inDays + 1);
    return min(1.0, completionDates.length / daysSinceCreated);
  }

  int currentStreak({DateTime? referenceDate}) {
    final reference = dateOnly(referenceDate ?? DateTime.now());
    var cursor = isCompletedOn(reference)
        ? reference
        : reference.subtract(const Duration(days: 1));

    if (!isCompletedOn(cursor)) {
      return 0;
    }

    var streak = 0;
    while (isCompletedOn(cursor)) {
      streak++;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    return streak;
  }

  bool get isCompletedToday => isCompletedOn(DateTime.now());

  List<String> sortedCompletionKeys() {
    final list = completionDates.toList();
    list.sort((a, b) => parseDateKey(b).compareTo(parseDateKey(a)));
    return list;
  }

  static List<Habit> sampleHabits() {
    return [
      Habit(
        id: 'habit-1',
        title: 'Morning Run',
        description: 'A 20-minute run to start the day with energy.',
        category: 'Fitness',
        dailyTarget: 1,
        createdAt: DateTime.now().subtract(const Duration(days: 16)),
        completionDates: _historyFromOffsets([0, 1, 2, 4, 5, 7, 8, 9, 10]),
        color: 'ocean',
        icon: 'directions_run',
      ),
      Habit(
        id: 'habit-2',
        title: 'Read 20 Pages',
        description: 'Read a focused chunk of a book before bedtime.',
        category: 'Learning',
        dailyTarget: 1,
        createdAt: DateTime.now().subtract(const Duration(days: 9)),
        completionDates: _historyFromOffsets([1, 2, 3, 4, 6, 8]),
        color: 'amber',
        icon: 'book',
      ),
      Habit(
        id: 'habit-3',
        title: 'Drink Water',
        description: 'Track healthy hydration throughout the day.',
        category: 'Wellness',
        dailyTarget: 8,
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
        completionDates: _historyFromOffsets([0, 1, 2, 3, 4, 5, 6, 7, 8, 10, 12]),
        dailyProgress: _progressFromOffsets([0, 1, 2, 3, 4, 5, 6, 7, 8, 10, 12], 8),
        color: 'indigo',
        icon: 'water_drop',
      ),
    ];
  }

  static Set<String> _historyFromOffsets(List<int> offsets) {
    return offsets
        .map((offset) => dateKey(DateTime.now().subtract(Duration(days: offset))))
        .toSet();
  }

  static Map<String, int> _progressFromOffsets(List<int> offsets, int target) {
    final Map<String, int> progress = <String, int>{};
    for (final offset in offsets) {
      final key = dateKey(DateTime.now().subtract(Duration(days: offset)));
      progress[key] = target;
    }
    return progress;
  }

  factory Habit.fromJson(Map<String, dynamic> json) {
    final rawProgress = json['dailyProgress'] as Map<String, dynamic>?;
    final Map<String, int> progress = rawProgress != null
        ? rawProgress.map((k, v) => MapEntry<String, int>(k, v as int))
        : const <String, int>{};

    return Habit(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      category: json['category'] as String? ?? 'General',
      dailyTarget: json['dailyTarget'] as int? ?? 1,
      createdAt: json['createdAt'] is int
          ? DateTime.fromMillisecondsSinceEpoch(json['createdAt'] as int)
          : DateTime.parse(json['createdAt'] as String),
      completionDates: (json['completionDates'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toSet() ??
          const <String>{},
      dailyProgress: progress,
      color: json['color'] as String? ?? 'emerald',
      icon: json['icon'] as String? ?? 'track_changes',
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'dailyTarget': dailyTarget,
      'createdAt': createdAt.toIso8601String(),
      'completionDates': completionDates.toList(),
      'dailyProgress': dailyProgress,
      'color': color,
      'icon': icon,
    };
  }
}
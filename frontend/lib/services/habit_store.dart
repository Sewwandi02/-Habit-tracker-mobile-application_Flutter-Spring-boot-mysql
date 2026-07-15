import 'dart:convert';
import 'package:flutter/foundation.dart';

import '../models/habit.dart';
import '../utils/date_utils.dart';
import 'api_client.dart';

class HabitStore extends ChangeNotifier {
  HabitStore() : _habits = <Habit>[];

  List<Habit> _habits;

  List<Habit> get habits {
    final copy = List<Habit>.from(_habits);
    copy.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return copy;
  }

  Habit? habitById(String habitId) {
    for (final habit in _habits) {
      if (habit.id == habitId) {
        return habit;
      }
    }
    return null;
  }

  Future<void> fetchHabits() async {
    try {
      final response = await ApiClient.instance.get('/api/habits');
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
        _habits = data.map((json) => Habit.fromJson(json as Map<String, dynamic>)).toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error fetching habits: $e');
    }
  }

  void clearHabits() {
    _habits = <Habit>[];
    notifyListeners();
  }

  Future<void> addHabit(Habit habit) async {
    // Optimistic UI update
    _habits = <Habit>[habit, ..._habits];
    notifyListeners();

    try {
      final response = await ApiClient.instance.post('/api/habits', habit.toJson());
      if (response.statusCode == 201) {
        final returnedHabit = Habit.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
        _habits = _habits.map((h) => h.id == habit.id ? returnedHabit : h).toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error adding habit: $e');
      // Rollback optimistic update
      _habits = _habits.where((h) => h.id != habit.id).toList();
      notifyListeners();
    }
  }

  Future<void> updateHabit(Habit updatedHabit) async {
    final original = habitById(updatedHabit.id);
    if (original == null) return;

    // Optimistic UI update
    _habits = _habits
        .map((habit) => habit.id == updatedHabit.id ? updatedHabit : habit)
        .toList();
    notifyListeners();

    try {
      final response = await ApiClient.instance.put('/api/habits/${updatedHabit.id}', updatedHabit.toJson());
      if (response.statusCode == 200) {
        final returnedHabit = Habit.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
        _habits = _habits.map((h) => h.id == updatedHabit.id ? returnedHabit : h).toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error updating habit: $e');
      // Rollback optimistic update
      _habits = _habits.map((h) => h.id == updatedHabit.id ? original : h).toList();
      notifyListeners();
    }
  }

  Future<void> deleteHabit(String habitId) async {
    final original = habitById(habitId);
    if (original == null) return;

    // Optimistic UI update
    _habits = _habits.where((habit) => habit.id != habitId).toList();
    notifyListeners();

    try {
      final response = await ApiClient.instance.delete('/api/habits/$habitId');
      if (response.statusCode != 204 && response.statusCode != 200) {
        // Rollback
        _habits = <Habit>[original, ..._habits];
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error deleting habit: $e');
      // Rollback
      _habits = <Habit>[original, ..._habits];
      notifyListeners();
    }
  }

  Future<void> toggleTodayCompletion(String habitId) async {
    final habit = habitById(habitId);
    if (habit == null) return;

    // Optimistic UI update
    final updated = habit.toggleForDate(DateTime.now());
    _habits = _habits.map((h) => h.id == habitId ? updated : h).toList();
    notifyListeners();

    try {
      final response = await ApiClient.instance.post('/api/habits/$habitId/toggle');
      if (response.statusCode == 200) {
        final returnedHabit = Habit.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
        _habits = _habits.map((h) => h.id == habitId ? returnedHabit : h).toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error toggling habit completion: $e');
      // Rollback
      _habits = _habits.map((h) => h.id == habitId ? habit : h).toList();
      notifyListeners();
    }
  }

  Future<void> updateProgress(String habitId, DateTime date, int progress) async {
    final habit = habitById(habitId);
    if (habit == null) return;

    final key = dateKey(date);
    
    // Calculate new completions list locally for optimistic UI
    final updatedCompletions = Set<String>.from(habit.completionDates);
    if (progress >= habit.dailyTarget) {
      updatedCompletions.add(key);
    } else {
      updatedCompletions.remove(key);
    }

    final updatedProgress = Map<String, int>.from(habit.dailyProgress);
    updatedProgress[key] = progress;

    final updatedHabit = habit.copyWith(
      completionDates: updatedCompletions,
      dailyProgress: updatedProgress,
    );

    // Optimistic UI update
    _habits = _habits.map((h) => h.id == habitId ? updatedHabit : h).toList();
    notifyListeners();

    try {
      final response = await ApiClient.instance.post(
        '/api/habits/$habitId/progress',
        <String, dynamic>{
          'date': key,
          'progress': progress,
        },
      );
      if (response.statusCode == 200) {
        final returnedHabit = Habit.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
        _habits = _habits.map((h) => h.id == habitId ? returnedHabit : h).toList();
        notifyListeners();
      } else {
        // Rollback
        _habits = _habits.map((h) => h.id == habitId ? habit : h).toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error updating habit progress: $e');
      // Rollback
      _habits = _habits.map((h) => h.id == habitId ? habit : h).toList();
      notifyListeners();
    }
  }
}
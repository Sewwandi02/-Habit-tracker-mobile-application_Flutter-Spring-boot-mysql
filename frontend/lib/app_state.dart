import 'package:flutter/material.dart';

import 'models/habit.dart';
import 'services/auth_service.dart';
import 'services/habit_store.dart';

import 'services/api_client.dart';

class AppState extends ChangeNotifier {
  AppState()
      : authService = AuthService(),
        habitStore = HabitStore() {
    habitStore.addListener(_handleStoreChanged);
    init();
  }

  final AuthService authService;
  final HabitStore habitStore;

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  Future<void> init() async {
    await ApiClient.instance.init();
    if (authService.isLoggedIn) {
      await habitStore.fetchHabits();
    }
    _isInitialized = true;
    notifyListeners();
  }

  Future<String?> login(String email, String password) async {
    final error = await authService.login(email, password);
    if (error == null) {
      await habitStore.fetchHabits();
      notifyListeners();
    }
    return error;
  }

  Future<String?> signUp(String email, String password) async {
    final error = await authService.signUp(email, password);
    if (error == null) {
      habitStore.clearHabits();
      notifyListeners();
    }
    return error;
  }

  Future<void> logout() async {
    await authService.logout();
    habitStore.clearHabits();
    notifyListeners();
  }

  Future<void> addHabit(Habit habit) async {
    await habitStore.addHabit(habit);
  }

  Future<void> updateHabit(Habit habit) async {
    await habitStore.updateHabit(habit);
  }

  Future<void> deleteHabit(String habitId) async {
    await habitStore.deleteHabit(habitId);
  }

  Future<void> toggleTodayCompletion(String habitId) async {
    await habitStore.toggleTodayCompletion(habitId);
  }

  Future<void> updateProgress(String habitId, DateTime date, int progress) async {
    await habitStore.updateProgress(habitId, date, progress);
  }

  void _handleStoreChanged() {
    notifyListeners();
  }

  @override
  void dispose() {
    habitStore.removeListener(_handleStoreChanged);
    habitStore.dispose();
    super.dispose();
  }
}

class AppStateScope extends InheritedNotifier<AppState> {
  const AppStateScope({
    super.key,
    required super.notifier,
    required super.child,
  });

  static AppState of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppStateScope>();
    assert(scope != null, 'AppStateScope not found in widget tree');
    return scope!.notifier!;
  }
}
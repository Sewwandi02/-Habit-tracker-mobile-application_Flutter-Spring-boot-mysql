import 'package:flutter/material.dart';

import '../app_state.dart';
import '../models/habit.dart';
import '../utils/constants.dart';
import '../widgets/add_habit_dialog.dart';
import '../widgets/habit_card.dart';
import 'analytics_screen.dart';
import 'auth_screen.dart';
import 'habit_details_screen.dart';
import 'landing_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;
  String _selectedCategory = 'All';
  String _searchQuery = '';
  String _sortBy = 'created'; // 'created' | 'streak' | 'title'

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);
    final userEmail = appState.authService.currentUserEmail ?? 'user@habittracker.app';

    final screens = <Widget>[
      _buildHabitsTab(context, appState),
      const AnalyticsScreen(),
      _SettingsView(
        email: userEmail,
        onLogout: () => _handleLogout(context, appState),
      ),
    ];

    return Scaffold(
      body: SafeArea(
        child: screens[_currentIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey.shade500,
        showUnselectedLabels: true,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.playlist_add_check_rounded),
            label: 'Habits',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_rounded),
            label: 'Analytics',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  Widget _buildHabitsTab(BuildContext context, AppState appState) {
    final habits = appState.habitStore.habits;

    // Filter by Category and Search Query
    final filteredHabits = habits.where((habit) {
      final matchesCategory = _selectedCategory == 'All' || habit.category == _selectedCategory;
      final matchesSearch = habit.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          habit.description.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();

    // Sort habits list
    if (_sortBy == 'streak') {
      filteredHabits.sort((a, b) => b.currentStreak().compareTo(a.currentStreak()));
    } else if (_sortBy == 'title') {
      filteredHabits.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
    } else {
      // default: newest first (created)
      filteredHabits.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Habits', style: TextStyle(fontWeight: FontWeight.w800)),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort_rounded),
            tooltip: 'Sort habits',
            onSelected: (value) {
              setState(() {
                _sortBy = value;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'created',
                child: Text('Sort by: Date Created'),
              ),
              const PopupMenuItem(
                value: 'streak',
                child: Text('Sort by: Active Streak'),
              ),
              const PopupMenuItem(
                value: 'title',
                child: Text('Sort by: Title (A-Z)'),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openHabitDialog(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Habit'),
      ),
      body: Column(
        children: [
          // Search Box
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Search habits...',
                prefixIcon: const Icon(Icons.search_rounded),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                fillColor: Colors.grey.shade100,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          
          // Category Chips Bar
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: ['All', ...AppConstants.habitCategories].map((category) {
                final isSelected = _selectedCategory == category;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (_) {
                      setState(() {
                        _selectedCategory = category;
                      });
                    },
                    selectedColor: Theme.of(context).colorScheme.primaryContainer,
                    labelStyle: TextStyle(
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Colors.black87,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    side: BorderSide(
                      color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey.shade300,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 10),

          // Habit List
          Expanded(
            child: filteredHabits.isEmpty
                ? _EmptyHabitState(
                    hasFilters: _searchQuery.isNotEmpty || _selectedCategory != 'All',
                    onCreateHabit: () => _openHabitDialog(context),
                    onClearFilters: () {
                      setState(() {
                        _searchQuery = '';
                        _selectedCategory = 'All';
                      });
                    },
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                    itemBuilder: (context, index) {
                      final habit = filteredHabits[index];
                      return Dismissible(
                        key: ValueKey<String>(habit.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.red.shade400,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: const Icon(Icons.delete_outline_rounded, color: Colors.white),
                        ),
                        confirmDismiss: (_) async {
                          return await showDialog<bool>(
                                context: context,
                                builder: (dialogContext) {
                                  return AlertDialog(
                                    title: const Text('Delete habit?'),
                                    content: Text('Delete "${habit.title}" from your tracker?'),
                                    actions: <Widget>[
                                      TextButton(
                                        onPressed: () => Navigator.of(dialogContext).pop(false),
                                        child: const Text('Cancel'),
                                      ),
                                      FilledButton(
                                        onPressed: () => Navigator.of(dialogContext).pop(true),
                                        child: const Text('Delete'),
                                      ),
                                    ],
                                  );
                                },
                              ) ??
                              false;
                        },
                        onDismissed: (_) => appState.deleteHabit(habit.id),
                        child: HabitCard(
                          habit: habit,
                          progress: habit.weeklyCompletionRatio(),
                          onTap: () => _editHabit(context, habit),
                          onDetailsPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => HabitDetailsScreen(habitId: habit.id),
                              ),
                            );
                          },
                          onEditPressed: () => _editHabit(context, habit),
                          onToggleToday: () => appState.toggleTodayCompletion(habit.id),
                          onProgressChanged: (newVal) => appState.updateProgress(habit.id, DateTime.now(), newVal),
                        ),
                      );
                    },
                    separatorBuilder: (context, index) => const SizedBox(height: 14),
                    itemCount: filteredHabits.length,
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _openHabitDialog(BuildContext context, {Habit? habit}) async {
    final appState = AppStateScope.of(context);
    final result = await showHabitDialog(context, existingHabit: habit);

    if (result == null || !context.mounted) {
      return;
    }

    final now = DateTime.now();
    final updatedHabit = habit == null
        ? Habit(
            id: now.millisecondsSinceEpoch.toString(),
            title: result.title,
            description: result.description,
            category: result.category,
            dailyTarget: result.dailyTarget,
            createdAt: now,
            color: result.color,
            icon: result.icon,
          )
        : habit.copyWith(
            title: result.title,
            description: result.description,
            category: result.category,
            dailyTarget: result.dailyTarget,
            color: result.color,
            icon: result.icon,
          );

    if (habit == null) {
      appState.addHabit(updatedHabit);
    } else {
      appState.updateHabit(updatedHabit);
    }
  }

  Future<void> _editHabit(BuildContext context, Habit habit) {
    return _openHabitDialog(context, habit: habit);
  }

  Future<void> _handleLogout(BuildContext context, AppState appState) async {
    final shouldLogout = await showDialog<bool>(
          context: context,
          builder: (dialogContext) {
            return AlertDialog(
              title: const Text('Logout'),
              content: const Text('Do you want to sign out of Habit Tracker?'),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(dialogContext).pop(true),
                  child: const Text('Logout'),
                ),
              ],
            );
          },
        ) ??
        false;

    if (!shouldLogout || !context.mounted) {
      return;
    }

    final navigator = Navigator.of(context);
    await appState.logout();
    navigator.pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const LandingScreen()),
      (route) => false,
    );
  }
}

class _EmptyHabitState extends StatelessWidget {
  const _EmptyHabitState({
    required this.onCreateHabit,
    required this.hasFilters,
    required this.onClearFilters,
  });

  final VoidCallback onCreateHabit;
  final bool hasFilters;
  final VoidCallback onClearFilters;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              height: 96,
              width: 96,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(28),
              ),
              child: Icon(
                hasFilters ? Icons.search_off_rounded : Icons.checklist_rounded,
                size: 52,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              hasFilters ? 'No habits found' : 'No habits yet',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              hasFilters
                  ? 'Try relaxing your category filter or search keywords.'
                  : 'Create your first habit to start tracking progress and streaks.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.black54),
            ),
            const SizedBox(height: 20),
            if (hasFilters)
              OutlinedButton.icon(
                onPressed: onClearFilters,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Clear Filters'),
              )
            else
              FilledButton.icon(
                onPressed: onCreateHabit,
                icon: const Icon(Icons.add_rounded),
                label: const Text('Add Habit'),
              ),
          ],
        ),
      ),
    );
  }
}

class _SettingsView extends StatelessWidget {
  const _SettingsView({required this.email, required this.onLogout});
  final String email;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight,
            ),
            child: IntrinsicHeight(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 20),
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.person_rounded,
                          size: 64,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: Text(
                        email,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Center(
                      child: Text(
                        'Habit Tracker Account',
                        style: TextStyle(color: Colors.black54, fontSize: 13),
                      ),
                    ),
                    const SizedBox(height: 40),
                    const Text(
                      'Preferences',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 10),
                    Card(
                      child: Column(
                        children: [
                          ListTile(
                            leading: const Icon(Icons.color_lens_outlined),
                            title: const Text('Theme Settings'),
                            subtitle: const Text('Seed Color: Emerald Green'),
                            trailing: Container(
                              width: 24,
                              height: 24,
                              decoration: const BoxDecoration(
                                color: Color(0xFF136F63),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                          const Divider(height: 1),
                          const ListTile(
                            leading: Icon(Icons.info_outline_rounded),
                            title: Text('Version'),
                            trailing: Text('1.0.0'),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.red.shade400,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                      ),
                      onPressed: onLogout,
                      icon: const Icon(Icons.logout_rounded),
                      label: const Text('Log Out'),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
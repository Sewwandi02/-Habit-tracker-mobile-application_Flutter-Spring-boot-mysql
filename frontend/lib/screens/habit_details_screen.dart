import 'package:flutter/material.dart';

import '../app_state.dart';
import '../models/habit.dart';
import '../utils/constants.dart';
import '../utils/date_utils.dart';
import '../widgets/add_habit_dialog.dart';

class HabitDetailsScreen extends StatelessWidget {
  const HabitDetailsScreen({super.key, required this.habitId});

  final String habitId;

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);
    final habit = appState.habitStore.habitById(habitId);

    if (habit == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Habit Details')),
        body: const Center(child: Text('Habit not found.')),
      );
    }

    final habitColor = AppConstants.habitColors[habit.color] ?? Theme.of(context).colorScheme.primary;

    final weeklyRatio = habit.weeklyCompletionRatio();
    final lifetimeRatio = habit.lifetimeCompletionRatio();
    final streak = habit.currentStreak();
    final todayProgress = habit.getProgressForDate(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Habit Details'),
        actions: <Widget>[
          IconButton(
            tooltip: 'Edit habit',
            onPressed: () async {
              final result = await showHabitDialog(context, existingHabit: habit);
              if (result == null || !context.mounted) {
                return;
              }

              appState.updateHabit(
                habit.copyWith(
                  title: result.title,
                  description: result.description,
                  category: result.category,
                  dailyTarget: result.dailyTarget,
                  color: result.color,
                  icon: result.icon,
                ),
              );
            },
            icon: const Icon(Icons.edit_outlined),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _HeaderCard(habit: habit, streak: streak, weeklyRatio: weeklyRatio, habitColor: habitColor),
              const SizedBox(height: 16),
              Row(
                children: <Widget>[
                  Expanded(
                    child: _StatCard(
                      title: 'Streak',
                      value: '$streak days',
                      icon: Icons.local_fire_department_rounded,
                      habitColor: habitColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      title: 'Progress',
                      value: '${(lifetimeRatio * 100).round()}%',
                      icon: Icons.pie_chart_rounded,
                      habitColor: habitColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      title: 'Week',
                      value: '${(weeklyRatio * 100).round()}%',
                      icon: Icons.query_stats_rounded,
                      habitColor: habitColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Text(
                        'Today',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        habit.isCompletedToday
                            ? 'You have already completed this habit today.'
                            : 'Log your progress or complete the habit today.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.black54),
                      ),
                      const SizedBox(height: 16),
                      if (habit.dailyTarget > 1) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            IconButton.filledTonal(
                              style: IconButton.styleFrom(
                                foregroundColor: habitColor,
                                backgroundColor: habitColor.withValues(alpha: 0.1),
                              ),
                              onPressed: todayProgress > 0
                                  ? () => appState.updateProgress(habit.id, DateTime.now(), todayProgress - 1)
                                  : null,
                              icon: const Icon(Icons.remove_rounded),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 24),
                              child: Text(
                                '$todayProgress / ${habit.dailyTarget}',
                                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: habit.isCompletedToday ? habitColor : Colors.black87,
                                    ),
                              ),
                            ),
                            IconButton.filledTonal(
                              style: IconButton.styleFrom(
                                foregroundColor: habitColor,
                                backgroundColor: habitColor.withValues(alpha: 0.1),
                              ),
                              onPressed: todayProgress < habit.dailyTarget
                                  ? () => appState.updateProgress(habit.id, DateTime.now(), todayProgress + 1)
                                  : null,
                              icon: const Icon(Icons.add_rounded),
                            ),
                          ],
                        ),
                      ] else ...[
                        FilledButton.icon(
                          style: FilledButton.styleFrom(backgroundColor: habitColor),
                          onPressed: () {
                            appState.toggleTodayCompletion(habit.id);
                          },
                          icon: Icon(habit.isCompletedToday ? Icons.check_circle_rounded : Icons.done_rounded),
                          label: Text(habit.isCompletedToday ? 'Completed today' : 'Mark completed for today'),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _WeeklyChart(habit: habit, habitColor: habitColor),
              const SizedBox(height: 16),
              _CompletionHistory(habit: habit, habitColor: habitColor),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(foregroundColor: habitColor, side: BorderSide(color: habitColor)),
                onPressed: () async {
                  final result = await showHabitDialog(context, existingHabit: habit);
                  if (result == null || !context.mounted) {
                    return;
                  }

                  appState.updateHabit(
                    habit.copyWith(
                      title: result.title,
                      description: result.description,
                      category: result.category,
                      dailyTarget: result.dailyTarget,
                      color: result.color,
                      icon: result.icon,
                    ),
                  );
                },
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Edit habit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({
    required this.habit,
    required this.streak,
    required this.weeklyRatio,
    required this.habitColor,
  });

  final Habit habit;
  final int streak;
  final double weeklyRatio;
  final Color habitColor;

  @override
  Widget build(BuildContext context) {
    final habitIcon = AppConstants.habitIcons[habit.icon] ?? Icons.track_changes_rounded;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  height: 56,
                  width: 56,
                  decoration: BoxDecoration(
                    color: habitColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Icon(
                    habitIcon,
                    color: habitColor,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        habit.title,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        habit.description,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.black54),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: <Widget>[
                _InfoChip(label: habit.category, icon: Icons.category_outlined),
                _InfoChip(label: 'Target ${habit.dailyTarget}/day', icon: Icons.flag_outlined),
                _InfoChip(label: 'Created ${formatDateLabel(habit.createdAt)}', icon: Icons.event_outlined),
                _InfoChip(label: '$streak day streak', icon: Icons.local_fire_department_outlined),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: weeklyRatio,
                minHeight: 10,
                backgroundColor: habitColor.withValues(alpha: 0.1),
                valueColor: AlwaysStoppedAnimation<Color>(habitColor),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${(weeklyRatio * 100).round()}% weekly completion',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.habitColor,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color habitColor;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Icon(icon, color: habitColor),
            const SizedBox(height: 14),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}

class _WeeklyChart extends StatelessWidget {
  const _WeeklyChart({
    required this.habit,
    required this.habitColor,
  });

  final Habit habit;
  final Color habitColor;

  @override
  Widget build(BuildContext context) {
    final days = lastDays(7);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Weekly completion chart',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 160,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: days.map((day) {
                  final completed = habit.isCompletedOn(day);
                  return Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          height: completed ? 110 : 26,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            color: completed
                                ? habitColor
                                : habitColor.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          weekdayLabel(day),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CompletionHistory extends StatelessWidget {
  const _CompletionHistory({
    required this.habit,
    required this.habitColor,
  });

  final Habit habit;
  final Color habitColor;

  @override
  Widget build(BuildContext context) {
    final historyDays = lastDays(28);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Calendar history',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              'A quick snapshot of the last 28 days.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.black54),
            ),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: historyDays.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 0.82,
              ),
              itemBuilder: (context, index) {
                final day = historyDays[index];
                final completed = habit.isCompletedOn(day);
                return Container(
                  decoration: BoxDecoration(
                    color: completed
                        ? habitColor.withValues(alpha: 0.15)
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: completed
                          ? habitColor.withValues(alpha: 0.3)
                          : Colors.grey.shade200,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          '${day.day}',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: completed
                                    ? habitColor
                                    : Colors.black87,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          weekdayLabel(day),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: completed
                                    ? habitColor
                                    : Colors.black45,
                              ),
                        ),
                        const SizedBox(height: 6),
                        Icon(
                          completed ? Icons.check_rounded : Icons.remove_rounded,
                          size: 16,
                          color: completed
                              ? habitColor
                              : Colors.black26,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
      side: BorderSide.none,
    );
  }
}
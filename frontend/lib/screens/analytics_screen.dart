import 'package:flutter/material.dart';
import 'dart:math';

import '../app_state.dart';
import '../models/habit.dart';
import '../utils/date_utils.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);
    final habits = appState.habitStore.habits;

    if (habits.isEmpty) {
      return const Scaffold(
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(Icons.bar_chart_rounded, size: 72, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No analytics available',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  'Create and complete habits to see statistical breakdowns here.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black54),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Stats calculations
    final totalHabits = habits.length;
    final completedToday = habits.where((h) => h.isCompletedToday).length;
    
    // Streaks
    int maxStreak = 0;
    for (final habit in habits) {
      maxStreak = max(maxStreak, habit.currentStreak());
    }

    // Category Distribution
    final Map<String, List<Habit>> habitsByCategory = {};
    for (final habit in habits) {
      habitsByCategory.putIfAbsent(habit.category, () => []).add(habit);
    }

    // Heatmap calculations
    final days = lastDays(28);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // Overview cards
              Row(
                children: <Widget>[
                  Expanded(
                    child: _MetricCard(
                      title: 'Completed Today',
                      value: '$completedToday / $totalHabits',
                      subtitle: 'habits complete',
                      icon: Icons.check_circle_rounded,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _MetricCard(
                      title: 'Best Streak',
                      value: '$maxStreak days',
                      subtitle: 'longest active streak',
                      icon: Icons.local_fire_department_rounded,
                      color: Colors.orange.shade700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Heatmap Graph
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Combined Heatmap',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Completion rate over the last 28 days across all habits.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.black54),
                      ),
                      const SizedBox(height: 20),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: days.length,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 7,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                          childAspectRatio: 1.0,
                        ),
                        itemBuilder: (context, index) {
                          final day = days[index];
                          
                          // Calculate completion ratio for this day
                          int completedOnDay = 0;
                          for (final h in habits) {
                            if (h.isCompletedOn(day)) {
                              completedOnDay++;
                            }
                          }

                          final ratio = totalHabits > 0 ? completedOnDay / totalHabits : 0.0;
                          final primaryColor = Theme.of(context).colorScheme.primary;

                          Color cellColor = Colors.grey.shade100;
                          if (ratio > 0 && ratio <= 0.34) {
                            cellColor = primaryColor.withValues(alpha: 0.25);
                          } else if (ratio > 0.34 && ratio <= 0.67) {
                            cellColor = primaryColor.withValues(alpha: 0.55);
                          } else if (ratio > 0.67) {
                            cellColor = primaryColor;
                          }

                          return Container(
                            decoration: BoxDecoration(
                              color: cellColor,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.grey.shade200, width: 1),
                            ),
                            child: Tooltip(
                              message: '${formatDateLabel(day)}: $completedOnDay completed',
                              child: Center(
                                child: Text(
                                  '${day.day}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: ratio > 0.67 ? Colors.white : Colors.black87,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 14),
                      // Legend
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          const Text('Less ', style: TextStyle(fontSize: 10, color: Colors.black54)),
                          _LegendBox(color: Colors.grey.shade100),
                          _LegendBox(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.25)),
                          _LegendBox(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.55)),
                          _LegendBox(color: Theme.of(context).colorScheme.primary),
                          const Text(' More', style: TextStyle(fontSize: 10, color: Colors.black54)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Category Breakdown
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Category Distribution',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      ...habitsByCategory.entries.map((entry) {
                        final catName = entry.key;
                        final catHabits = entry.value;
                        
                        // Calculate completions in this category
                        int completions = 0;
                        for (final h in catHabits) {
                          completions += h.completionDates.length;
                        }
                        
                        final double catScore = catHabits.isEmpty 
                            ? 0.0 
                            : completions / (catHabits.length * 7.0); // Rough index score
                        final displayProgress = min(1.0, catScore);

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Text(
                                    catName,
                                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                                  ),
                                  Text(
                                    '${catHabits.length} habits',
                                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(999),
                                child: LinearProgressIndicator(
                                  value: displayProgress,
                                  minHeight: 8,
                                  backgroundColor: Colors.grey.shade100,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black54),
                ),
                Icon(icon, color: color, size: 20),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.black87),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 11, color: Colors.black45),
            ),
          ],
        ),
      ),
    );
  }
}

class _LegendBox extends StatelessWidget {
  const _LegendBox({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(3),
        border: Border.all(color: Colors.grey.shade300, width: 0.5),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../models/habit.dart';
import '../utils/constants.dart';

class HabitCard extends StatelessWidget {
  const HabitCard({
    super.key,
    required this.habit,
    required this.progress,
    required this.onTap,
    required this.onDetailsPressed,
    required this.onEditPressed,
    this.onToggleToday,
    this.onProgressChanged,
  });

  final Habit habit;
  final double progress;
  final VoidCallback onTap;
  final VoidCallback onDetailsPressed;
  final VoidCallback onEditPressed;
  final VoidCallback? onToggleToday;
  final ValueChanged<int>? onProgressChanged;

  @override
  Widget build(BuildContext context) {
    final habitColor = AppConstants.habitColors[habit.color] ?? Theme.of(context).colorScheme.primary;
    final habitIcon = AppConstants.habitIcons[habit.icon] ?? Icons.track_changes_rounded;

    final todayProgress = habit.getProgressForDate(DateTime.now());
    final dailyTarget = habit.dailyTarget;
    final isCompletedToday = habit.isCompletedToday;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    height: 52,
                    width: 52,
                    decoration: BoxDecoration(
                      color: habitColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      habitIcon,
                      color: habitColor,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          habit.title,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          habit.category,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.black54,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Edit habit',
                    onPressed: onEditPressed,
                    icon: const Icon(Icons.edit_outlined),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                habit.description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.black54),
              ),
              const SizedBox(height: 14),
              
              // Daily Interaction Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (dailyTarget > 1) ...[
                    Row(
                      children: [
                        IconButton.filledTonal(
                          style: IconButton.styleFrom(
                            foregroundColor: habitColor,
                            backgroundColor: habitColor.withValues(alpha: 0.1),
                          ),
                          onPressed: todayProgress > 0 && onProgressChanged != null
                              ? () => onProgressChanged!(todayProgress - 1)
                              : null,
                          icon: const Icon(Icons.remove_rounded),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            '$todayProgress / $dailyTarget',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: isCompletedToday ? habitColor : Colors.black87,
                                ),
                          ),
                        ),
                        IconButton.filledTonal(
                          style: IconButton.styleFrom(
                            foregroundColor: habitColor,
                            backgroundColor: habitColor.withValues(alpha: 0.1),
                          ),
                          onPressed: todayProgress < dailyTarget && onProgressChanged != null
                              ? () => onProgressChanged!(todayProgress + 1)
                              : null,
                          icon: const Icon(Icons.add_rounded),
                        ),
                      ],
                    ),
                  ] else ...[
                    GestureDetector(
                      onTap: onToggleToday,
                      child: Row(
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: isCompletedToday ? habitColor : Colors.transparent,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isCompletedToday ? habitColor : Colors.grey.shade400,
                                width: 2,
                              ),
                            ),
                            child: isCompletedToday
                                ? const Icon(Icons.check_rounded, color: Colors.white, size: 18)
                                : null,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            isCompletedToday ? 'Completed today' : 'Mark completed',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: isCompletedToday ? habitColor : Colors.black54,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  TextButton.icon(
                    onPressed: onDetailsPressed,
                    style: TextButton.styleFrom(foregroundColor: habitColor),
                    icon: const Icon(Icons.open_in_new_rounded, size: 18),
                    label: const Text('Details'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  backgroundColor: habitColor.withValues(alpha: 0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(habitColor),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    '${(progress * 100).round()}% weekly completion',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.black54,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  _StatusPill(
                    text: 'Streak: ${habit.currentStreak()}d',
                    habitColor: habitColor,
                    isPositive: habit.currentStreak() > 0,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({
    required this.text,
    required this.habitColor,
    required this.isPositive,
  });

  final String text;
  final Color habitColor;
  final bool isPositive;

  @override
  Widget build(BuildContext context) {
    final background = isPositive
        ? habitColor.withValues(alpha: 0.15)
        : Colors.grey.shade100;
    final foreground = isPositive
        ? habitColor
        : Colors.black54;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: foreground,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}
import 'package:flutter/material.dart';

class AppConstants {
  static const String appName = 'Habit Tracker';
  static const String landingHeadline = 'Welcome to Your Habit Tracker';
  static const String landingSubtitle = 'Build better habits, one day at a time.';
  static const String demoAuthHint = 'Local mock authentication is enabled. Try demo@habittracker.app / password123.';

  static const List<String> habitCategories = <String>[
    'Health',
    'Fitness',
    'Mindfulness',
    'Learning',
    'Productivity',
    'Wellness',
    'Other',
  ];

  static const Map<String, Color> habitColors = <String, Color>{
    'emerald': Color(0xFF0F766E),
    'tangerine': Color(0xFFEA580C),
    'indigo': Color(0xFF4F46E5),
    'crimson': Color(0xFFE11D48),
    'amber': Color(0xFFD97706),
    'amethyst': Color(0xFF9333EA),
    'ocean': Color(0xFF0284C7),
  };

  static const Map<String, IconData> habitIcons = <String, IconData>{
    'track_changes': Icons.track_changes_rounded,
    'directions_run': Icons.directions_run_rounded,
    'book': Icons.book_rounded,
    'water_drop': Icons.water_drop_rounded,
    'spa': Icons.spa_rounded,
    'hotel': Icons.hotel_rounded,
    'code': Icons.code_rounded,
    'fitness_center': Icons.fitness_center_rounded,
    'restaurant': Icons.restaurant_rounded,
    'brush': Icons.brush_rounded,
  };
}

class AppGradients {
  static const LinearGradient landingBackground = LinearGradient(
    colors: <Color>[Color(0xFF0F766E), Color(0xFF16A34A), Color(0xFFDBEAFE)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
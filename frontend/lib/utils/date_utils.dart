String dateKey(DateTime date) {
  final normalized = dateOnly(date);
  return '${normalized.year.toString().padLeft(4, '0')}-${normalized.month.toString().padLeft(2, '0')}-${normalized.day.toString().padLeft(2, '0')}';
}

DateTime dateOnly(DateTime date) {
  return DateTime(date.year, date.month, date.day);
}

DateTime parseDateKey(String key) {
  final parts = key.split('-');
  return DateTime(
    int.parse(parts[0]),
    int.parse(parts[1]),
    int.parse(parts[2]),
  );
}

List<DateTime> lastDays(int count, {DateTime? from}) {
  final reference = dateOnly(from ?? DateTime.now());
  return List<DateTime>.generate(count, (index) {
    return reference.subtract(Duration(days: count - 1 - index));
  });
}

String formatDateLabel(DateTime date) {
  const monthNames = <String>[
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  return '${monthNames[date.month - 1]} ${date.day}, ${date.year}';
}

String weekdayLabel(DateTime date) {
  const weekdayNames = <String>['M', 'T', 'W', 'T', 'F', 'S', 'S'];
  return weekdayNames[date.weekday - 1];
}
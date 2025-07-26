bool isHabitCompletedToday(List<DateTime> completedDate) {
  final today = DateTime.now();
  return completedDate.any((date) =>
      date.year == today.year &&
      date.month == today.month &&
      date.day == today.day
  );
}
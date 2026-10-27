const _months = [
  'ene', 'feb', 'mar', 'abr', 'may', 'jun',
  'jul', 'ago', 'sep', 'oct', 'nov', 'dic',
];

String formatDate(DateTime date) {
  final now = DateTime.now();
  final hour = date.hour.toString().padLeft(2, '0');
  final minute = date.minute.toString().padLeft(2, '0');

  final isToday =
      date.year == now.year && date.month == now.month && date.day == now.day;
  if (isToday) return 'Hoy, $hour:$minute';

  final yesterday = now.subtract(const Duration(days: 1));
  final isYesterday = date.year == yesterday.year &&
      date.month == yesterday.month &&
      date.day == yesterday.day;
  if (isYesterday) return 'Ayer, $hour:$minute';

  final base = '${date.day} ${_months[date.month - 1]}';
  return date.year == now.year ? base : '$base ${date.year}';
}

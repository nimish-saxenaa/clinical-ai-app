String getInitials(String name) {
  final parts = name.trim().split(RegExp(r'\s+'));

  if (parts.isEmpty) return '';

  return parts
      .where((part) => part.isNotEmpty)
      .map((part) => part[0])
      .join();
}

String formatDate(DateTime d) {
  const months = [
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

  return '${d.day} ${months[d.month - 1]} ${d.year}, ';
}
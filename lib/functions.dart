String getInitials(String name) {
  final parts = name.trim().split(RegExp(r'\s+'));

  if (parts.isEmpty) return '';

  return parts
      .where((part) => part.isNotEmpty)
      .map((part) => part[0].toUpperCase())
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

String getSpecialtyName(String specialty) {
  switch (specialty) {
    case "general_medicine":
      return "General Medicine";
    case "genecology":
      return "Women's Health";
    case "psychotherapy":
      return "Mental Health";
    default:
      return specialty;
  }
}

String getDiagnosisStatus(String status) {
  const statuses = {
    "diagnosis": "Diagnosed",
    "questionnaire": "In Progress",
  };

  return statuses[status] ?? status;
}
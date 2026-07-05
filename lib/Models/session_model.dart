class Session {
  final String? id;
  final String? date;
  final String? notes;
  final Map<String, dynamic> raw;

  Session({
    this.id,
    this.date,
    this.notes,
    required this.raw,
  });

  factory Session.fromJson(Map<String, dynamic> json) {
    return Session(
      id: json['id']?.toString(),
      date: json['date']?.toString() ?? json['created_at']?.toString(),
      notes: json['notes']?.toString(),
      raw: json,
    );
  }

  Map<String, dynamic> toJson() => raw;

  @override
  String toString() => 'Session(id: $id, date: $date, notes: $notes)';
}
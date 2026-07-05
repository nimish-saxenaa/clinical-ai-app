class Patient {
  final String id;
  final String name;
  final int age;
  final String? gender;
  final String? phone;
  final String? createdAt;
  final String? updatedAt;

  Patient({
    required this.id,
    required this.name,
    required this.age,
    this.gender,
    this.phone,
    this.createdAt,
    this.updatedAt,
  });

  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      // API sometimes returns "id", sometimes "patient_id"
      id: (json['id'] ?? json['patient_id'] ?? '').toString(),
      name: json['name'] ?? '',
      age: json['age'] is int
          ? json['age']
          : int.tryParse(json['age']?.toString() ?? '') ?? 0,
      gender: json['gender'],
      phone: json['phone'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'age': age,
      'gender': gender,
      'phone': phone,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  @override
  String toString() =>
      'Patient(id: $id, name: $name, age: $age, gender: $gender, phone: $phone)';
}
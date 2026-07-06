class Patient {
  final String patientId;
  final String? doctorId;
  final String name;
  final int age;
  final String? gender;
  final String? phone;
  final String? createdAt;
  final String? updatedAt;

  Patient({
    required this.patientId,
    this.doctorId,
    required this.name,
    required this.age,
    this.gender,
    this.phone,
    this.createdAt,
    this.updatedAt,
  });

  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      patientId: (json['patient_id'] ?? json['id'] ?? '').toString(),
      doctorId: json['doctor_id']?.toString(),
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
      'patient_id': patientId,
      'doctor_id': doctorId,
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
      'Patient(patientId: $patientId, name: $name, age: $age, gender: $gender, phone: $phone)';
}

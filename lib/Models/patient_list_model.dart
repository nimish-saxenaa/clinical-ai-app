import 'package:clinical_ai_app/Models/patient_model.dart';

class PatientListResponse {
  final List<Patient> patients;

  PatientListResponse({required this.patients});

  factory PatientListResponse.fromJson(Map<String, dynamic> json) {
    return PatientListResponse(
      patients: (json['patients'] as List<dynamic>? ?? [])
          .map((e) => Patient.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
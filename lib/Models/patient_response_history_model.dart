import 'package:clinical_ai_app/Models/patient_model.dart';
import 'package:clinical_ai_app/Models/session_model.dart';

class PatientHistoryResponse {
  final Patient patient;
  final List<Session> sessions;

  PatientHistoryResponse({
    required this.patient,
    required this.sessions,
  });

  factory PatientHistoryResponse.fromJson(Map<String, dynamic> json) {
    return PatientHistoryResponse(
      patient: Patient.fromJson(json['patient'] as Map<String, dynamic>? ?? {}),
      sessions: (json['sessions'] as List<dynamic>? ?? [])
          .map((e) => Session.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
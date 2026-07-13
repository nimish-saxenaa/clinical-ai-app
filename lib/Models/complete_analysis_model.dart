import 'package:clinical_ai_app/Models/session_model.dart';

class CompleteResponse {
  final String event;
  final SessionSummary note;
  final Diagnosis diagnosis;

  CompleteResponse({
    required this.event,
    required this.note,
    required this.diagnosis,
  });

  factory CompleteResponse.fromJson(Map<String, dynamic>? json) {
    json ??= {};

    return CompleteResponse(
      event: json['event']?.toString() ?? '',
      note: SessionSummary.fromJson(
        json['note'] as Map<String, dynamic>?,
      ),
      diagnosis: Diagnosis.fromJson(
        json['diagnosis'] as Map<String, dynamic>?,
      ),
    );
  }

  Map<String, dynamic> toJson() => {
    'event': event,
    'note': note.toJson(),
    'diagnosis': diagnosis.toJson(),
  };

  @override
  String toString() =>
      'CompleteResponse(event: $event)';
}
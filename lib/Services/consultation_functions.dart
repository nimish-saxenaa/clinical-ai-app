import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../Models/consultation_models.dart';
import 'dart:typed_data';

/// POST /api/v1/consultation/start
/// specialty must be one of: general_medicine | psychotherapy | gynecology
/// patient_id optional — if provided, overrides name/age/gender from the patient record.
///
String baseUrl = "https://med-history-agent.decrackle.io";
Future<StartConsultationResponse> startConsultation({
  required String baseUrl,
  required String token,
  required String specialty,
  String? patientLanguage,
  String? patientName,
  int? patientAge,
  String? patientGender,
  String? chiefComplaint,
  String? patientId,
}) async {
  Uri url = Uri.parse("$baseUrl/api/v1/consultation/start");
  final response = await http.post(
    url,
    headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    },
    body: jsonEncode({
      "specialty": specialty,
      "patient_language": ?patientLanguage,
      "patient_name": ?patientName,
      "patient_age": ?patientAge,
      "patient_gender": ?patientGender,
      "chief_complaint": ?chiefComplaint,
      "patient_id": ?patientId,
    }),
  );
  return StartConsultationResponse.fromJson(jsonDecode(response.body));
}

/// GET /api/v1/consultation/{session_id}
Future<SessionStateResponse> getSessionState({
  required String baseUrl,
  required String token,
  required String sessionId,
}) async {
  Uri url = Uri.parse("$baseUrl/api/v1/consultation/$sessionId");
  final response = await http.get(
    url,
    headers: {"Authorization": "Bearer $token"},
  );
  return SessionStateResponse.fromJson(jsonDecode(response.body));
}

/// POST /api/v1/consultation/{session_id}/answer
/// 400 if session not in questionnaire stage / no active question.
Future<SubmitAnswerResponse> submitAnswer({
  required String token,
  required String sessionId,
  required String answer,
}) async {
  Uri url = Uri.parse("$baseUrl/api/v1/consultation/$sessionId/answer");
  final response = await http.post(
    url,
    headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    },
    body: jsonEncode({"answer": answer}),
  );
  return SubmitAnswerResponse.fromJson(jsonDecode(response.body));
}

/// POST /api/v1/consultation/{session_id}/answer-audio
/// multipart/form-data upload of an audio file.
/// Uploads audio to R2, transcribes via Deepgram, optionally translates,
/// then processes like /answer. 400 if wrong stage / no active question.
Future<SubmitAnswerResponse> submitAnswerAudio({
  required String token,
  required String sessionId,
  required File audioFile,
}) async {
  Uri url = Uri.parse("$baseUrl/api/v1/consultation/$sessionId/answer-audio");
  final request = http.MultipartRequest("POST", url)
    ..headers["Authorization"] = "Bearer $token"
    ..files.add(await http.MultipartFile.fromPath("audio_file", audioFile.path));

  final streamedResponse = await request.send();
  final response = await http.Response.fromStream(streamedResponse);
  return SubmitAnswerResponse.fromJson(jsonDecode(response.body));
}

/// GET /api/v1/consultation/{session_id}/qa-log
Future<QaLogResponse> getQaLog({
  required String token,
  required String sessionId,
}) async {
  Uri url = Uri.parse("$baseUrl/api/v1/consultation/$sessionId/qa-log");
  final response = await http.get(
    url,
    headers: {"Authorization": "Bearer $token"},
  );
  return QaLogResponse.fromJson(jsonDecode(response.body));
}

/// PATCH /api/v1/consultation/{session_id}/answer/{question_id}
/// 404 if question_id not found in qa_log.
Future<EditAnswerResponse> editAnswer({
  required String token,
  required String sessionId,
  required String questionId,
  required String answer,
}) async {
  Uri url = Uri.parse("$baseUrl/api/v1/consultation/$sessionId/answer/$questionId");
  final response = await http.patch(
    url,
    headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    },
    body: jsonEncode({"answer": answer}),
  );
  return EditAnswerResponse.fromJson(jsonDecode(response.body));
}

/// POST /api/v1/consultation/{session_id}/prescribe
Future<PrescribeResponse> prescribe({
  required String token,
  required String sessionId,
  required String confirmedDiagnosis,
}) async {
  Uri url = Uri.parse("$baseUrl/api/v1/consultation/$sessionId/prescribe");
  final response = await http.post(
    url,
    headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    },
    body: jsonEncode({"confirmed_diagnosis": confirmedDiagnosis}),
  );
  return PrescribeResponse.fromJson(jsonDecode(response.body));
}

/// POST /api/v1/consultation/{session_id}/finalize
/// No body. Returns the full ConsultationContext object.
Future<ConsultationContext> finalizeConsultation({
  required String token,
  required String sessionId,
}) async {
  Uri url = Uri.parse("$baseUrl/api/v1/consultation/$sessionId/finalize");
  final response = await http.post(
    url,
    headers: {"Authorization": "Bearer $token"},
  );
  return ConsultationContext.fromJson(jsonDecode(response.body));
}

/// POST /api/v1/consultation/{session_id}/override
/// field: name of a ConsultationContext attribute. value: any type. reason: optional.
Future<OverrideFieldResponse> overrideField({
  required String token,
  required String sessionId,
  required String field,
  required dynamic value,
  String? reason,
}) async {
  Uri url = Uri.parse("$baseUrl/api/v1/consultation/$sessionId/override");
  final response = await http.post(
    url,
    headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    },
    body: jsonEncode({
      "field": field,
      "value": value,
      "reason": ?reason,
    }),
  );
  return OverrideFieldResponse.fromJson(jsonDecode(response.body));
}

/// DELETE /api/v1/consultation/{session_id}
/// Note: per API docs, this handler may currently raise a 500/TypeError
/// server-side due to a missing internal argument — test directly.
Future<DeleteConsultationResponse> deleteConsultation({
  required String token,
  required String sessionId,
}) async {
  Uri url = Uri.parse("$baseUrl/api/v1/consultation/$sessionId");
  final response = await http.delete(
    url,
    headers: {"Authorization": "Bearer $token"},
  );
  return DeleteConsultationResponse.fromJson(jsonDecode(response.body));
}

Future<Uint8List> textToSpeech({
  required String token,
  required String text,
}) async {
  final uri = Uri.parse("$baseUrl/api/v1/note/speak");

  final response = await http.post(
    uri,
    headers: {
      "Authorization": "Bearer $token",
      "Content-Type": "application/json",
    },
    body: '{"text":"$text"}',
  );

  if (response.statusCode != 200) {
    throw Exception(
      "TTS failed (${response.statusCode}): ${response.body}",
    );
  }

  return response.bodyBytes;
}



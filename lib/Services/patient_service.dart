import 'dart:convert';
import 'package:http/http.dart' as http;
import '../Models/patient_list_model.dart';
import '../Models/patient_model.dart';
import '../Models/patient_response_history_model.dart';
import '../access_token.dart';

String baseUrl = "https://med-history-agent.decrackle.io";

Future<Patient> createPatient({
  required String name,
  required int age,
  String? gender,
  String? phone,
}) async {
  Uri url = Uri.parse("$baseUrl/api/v1/patients");
  String token = await AccessTokenService.getToken() ?? "";
  final response = await http.post(
    url,
    headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    },
    body: jsonEncode({
      "name": name,
      "age": age,
      "gender": ?gender,
      "phone": ?phone,
    }),
  );
  return Patient.fromJson(jsonDecode(response.body));
}

Future<PatientListResponse> listPatients() async {
  Uri url = Uri.parse("$baseUrl/api/v1/patients");
String token = await AccessTokenService.getToken() ?? "";
  final response = await http.get(
    url,
    headers: {"Authorization": "Bearer $token"},
  );
  return PatientListResponse.fromJson(jsonDecode(response.body));
}

Future<Patient> getPatient({
  required String patientId,
}) async {
  Uri url = Uri.parse("$baseUrl/api/v1/patients/$patientId");
String token = await AccessTokenService.getToken() ?? "";
  final response = await http.get(
    url,
    headers: {"Authorization": "Bearer $token"},
  );
  return Patient.fromJson(jsonDecode(response.body));
}

Future<PatientHistoryResponse> getPatientHistory({
  required String patientId,
}) async {
  Uri url = Uri.parse("$baseUrl/api/v1/patients/$patientId/history");
  String token = await AccessTokenService.getToken() ?? "";
  final response = await http.get(
    url,
    headers: {"Authorization": "Bearer $token"},
  );
  return PatientHistoryResponse.fromJson(jsonDecode(response.body));
}

Future<Patient> updatePatient({
  required String patientId,
  String? name,
  int? age,
  String? gender,
  String? phone,
}) async {
  Uri url = Uri.parse("$baseUrl/api/v1/patients/$patientId");
String token = await AccessTokenService.getToken() ?? "";
  final response = await http.patch(
    url,
    headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    },
    body: jsonEncode({
      "name": ?name,
      "age": ?age,
      "gender": ?gender,
      "phone": ?phone,
    }),
  );
  return Patient.fromJson(jsonDecode(response.body));
}
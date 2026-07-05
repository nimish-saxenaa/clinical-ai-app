import 'package:clinical_ai_app/Services/patient_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

String baseUrl = "https://med-history-agent.decrackle.io";

Future<Map<String, dynamic>> login({
  required String email,
  required String password,
}) async {
  Uri url = Uri.parse(
    "$baseUrl/api/v1/auth/login",
  );
  final response = await http.post(
    url,
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({"email": email, "password": password}),
  );
  return jsonDecode(response.body);
}

Future<Map<String, dynamic>> createAccount({
  required String name,
  required String email,
  required String password,
}) async {
  Uri url = Uri.parse(
    "$baseUrl/api/v1/auth/register",
  );
  final response = await http.post(
    url,
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({"name": name, "email": email, "password": password}),
  );
  return jsonDecode(response.body);
}

Future<Map<String, dynamic>> refreshTokens({
  required String name,
  required String email,
  required String password,
}) async {
  Uri url = Uri.parse(
    "https://med-history-agent.decrackle.io/api/v1/auth/refresh",
  );
  final response = await http.post(
    url,
  );
  return jsonDecode(response.body);
}




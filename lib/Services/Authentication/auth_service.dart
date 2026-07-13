import 'package:clinical_ai_app/Services/PatientData/patient_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'access_token.dart';

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

Future<Map<String, dynamic>> refreshTokens() async {
  Uri url = Uri.parse(
    "$baseUrl/api/v1/auth/refresh",
  );
  final refreshToken = await AccessTokenService.getRequestToken();
  final response = await http.post(
    url,
    headers: {
      "Content-Type": "application/json",
      "Cookie": "refresh_token=$refreshToken",
    },
  );
  return jsonDecode(response.body);
}




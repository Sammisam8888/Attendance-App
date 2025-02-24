import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  final String baseUrl = "http://your-flask-backend.com";

  Future<bool> registerFingerprint(String userId, String fingerprintData) async {
    final response = await http.post(
      Uri.parse("$baseUrl/register-fingerprint"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"user_id": userId, "fingerprint_data": fingerprintData}),
    );
    return response.statusCode == 200;
  }

  Future<bool> verifyFingerprint(String userId, String fingerprintData) async {
    final response = await http.post(
      Uri.parse("$baseUrl/verify-fingerprint"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"user_id": userId, "fingerprint_data": fingerprintData}),
    );
    return response.statusCode == 200;
  }
}

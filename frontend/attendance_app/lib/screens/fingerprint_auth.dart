import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class FingerprintAuthScreen extends StatefulWidget {
  @override
  _FingerprintAuthScreenState createState() => _FingerprintAuthScreenState();
}

class _FingerprintAuthScreenState extends State<FingerprintAuthScreen> {
  final LocalAuthentication auth = LocalAuthentication();
  String _status = "Not Authenticated";

  Future<void> _authenticate() async {
    bool authenticated = false;
    try {
      authenticated = await auth.authenticate(
        localizedReason: "Authenticate to access the app",
        options: AuthenticationOptions(biometricOnly: true),
      );

      if (authenticated) {
        await _verifyFingerprintWithBackend();
      } else {
        setState(() {
          _status = "Authentication Failed";
        });
      }
    } catch (e) {
      setState(() {
        _status = "Error: ${e.toString()}";
      });
    }
  }

  Future<void> _verifyFingerprintWithBackend() async {
    final url = Uri.parse("http://your-flask-backend.com/verify-fingerprint");
    final data = jsonEncode({
      "user_id": "123456",
      "fingerprint_data": "SAMPLE_HASHED_DATA" // Replace with actual fingerprint data
    });

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: data,
    );

    if (response.statusCode == 200) {
      setState(() {
        _status = "Authentication Successful!";
      });
    } else {
      setState(() {
        _status = "Authentication Failed!";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Fingerprint Authentication")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_status, style: TextStyle(fontSize: 18)),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _authenticate,
              child: Text("Authenticate"),
            ),
          ],
        ),
      ),
    );
  }
}

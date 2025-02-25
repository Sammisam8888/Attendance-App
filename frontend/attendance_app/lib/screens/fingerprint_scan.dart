import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class FingerprintScanScreen extends StatefulWidget {
  const FingerprintScanScreen({super.key});

  @override
  _FingerprintScanScreenState createState() => _FingerprintScanScreenState();
}

class _FingerprintScanScreenState extends State<FingerprintScanScreen> {
  final LocalAuthentication auth = LocalAuthentication();
  bool _isAuthenticating = false;
  String _status = "Not Authorized";

  Future<void> _authenticate() async {
    bool authenticated = false;
    try {
      setState(() {
        _isAuthenticating = true;
        _status = "Authenticating...";
      });

      authenticated = await auth.authenticate(
        localizedReason: "Scan your fingerprint to register",
        options: AuthenticationOptions(biometricOnly: true),
      );

      setState(() {
        _isAuthenticating = false;
        _status = authenticated ? "Fingerprint Scanned" : "Failed to Authenticate";
      });

      if (authenticated) {
        await _sendFingerprintToBackend();
      }
    } catch (e) {
      setState(() {
        _isAuthenticating = false;
        _status = "Error: ${e.toString()}";
      });
    }
  }

  Future<void> _sendFingerprintToBackend() async {
    final url = Uri.parse("http://your-flask-backend.com/register-fingerprint");
    final data = jsonEncode({
      "user_id": "123456",  // Replace with actual user ID
      "fingerprint_data": "SAMPLE_HASHED_DATA" // Replace with actual fingerprint data if possible
    });

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: data,
    );

    if (response.statusCode == 200) {
      setState(() {
        _status = "Fingerprint Registered Successfully!";
      });
    } else {
      setState(() {
        _status = "Failed to Register Fingerprint!";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Fingerprint Registration")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_status, style: TextStyle(fontSize: 18)),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isAuthenticating ? null : _authenticate,
              child: Text("Register Fingerprint"),
            ),
          ],
        ),
      ),
    );
  }
}

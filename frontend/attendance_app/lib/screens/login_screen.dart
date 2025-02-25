import 'package:flutter/material.dart';
import 'fingerprint_scan.dart';
import 'fingerprint_auth.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Login")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FingerprintScanScreen()),
                );
              },
              child: Text("Register Fingerprint"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FingerprintAuthScreen()),
                );
              },
              child: Text("Authenticate with Fingerprint"),
            ),
          ],
        ),
      ),
    );
  }
}

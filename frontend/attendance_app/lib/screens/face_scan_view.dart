import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'success_view.dart'; // Import the success screen

class FaceScanScreen extends StatefulWidget {
  const FaceScanScreen({super.key, required this.qrCode}); // Convert 'key' to a super parameter

  final String qrCode; // The validated QR code

  @override
  FaceScanScreenState createState() => FaceScanScreenState();
}

class FaceScanScreenState extends State<FaceScanScreen> {
  bool isLoading = false;

  Future<void> _verifyFace() async {
    setState(() {
      isLoading = true;
    });

    final url = Uri.parse('http://your-backend-url/verify_face');
    // Trish update the backend URL for face verification

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"qr_code": widget.qrCode}), // Send QR code for verification
    );

    if (!mounted) return; // Add this check before using BuildContext

    setState(() {
      isLoading = false;
    });

    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);

      // Navigate to SuccessScreen after face verification
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => SuccessScreen(subject: result['subject'] ?? "Unknown Subject"),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Face verification failed ❌')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _verifyFace(); // Automatically verify face once this screen loads
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Face Recognition')),
      body: Center(
        child: isLoading
            ? CircularProgressIndicator() // Show loading animation while verifying
            : Text("Verifying Face..."),
      ),
    );
  }
}

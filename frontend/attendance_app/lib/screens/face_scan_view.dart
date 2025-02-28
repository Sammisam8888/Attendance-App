import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'success_view.dart'; // Import the success screen
import 'teacher_dashboard.dart';
import 'student_dashboard.dart';

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

    final url = Uri.parse('http://127.0.0.1:5000/verify_face'); // Update the backend URL for face verification

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
      final result = jsonDecode(response.body);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result["message"] ?? "Login Failed ❌")),
      );

      if (mounted) {
        if (result["role"] == 'Teacher') {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => TeacherDashboard()));
        } else {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => StudentDashboard()));
        }
      }
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

import 'package:flutter/material.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'face_scan_view.dart'; // Import the face recognition screen
import 'package:logging/logging.dart'; // Add this import

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key}); // Convert 'key' to a super parameter

  @override
  StudentDashboardState createState() => StudentDashboardState();
}

class StudentDashboardState extends State<StudentDashboard> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  String scannedData = "Scan a QR Code";
  final Logger logger = Logger('StudentDashboard'); // Add this line

  void _onQRViewCreated(QRViewController qrController) {
    controller = qrController;
    controller!.scannedDataStream.listen((scanData) async {
      setState(() {
        scannedData = scanData.code ?? "Invalid QR Code";
      });

      // Validate QR Code with backend
      bool isValid = await _sendQRToBackend(scanData.code ?? "");

      if (!mounted) return; // Add this check before using BuildContext

      if (isValid) {
        // Navigate to FaceScanScreen for face recognition
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FaceScanScreen(qrCode: scanData.code ?? ""),
            ),
          );
        }
      }
    });
  }

  Future<bool> _sendQRToBackend(String qrCode) async {
    if (qrCode.isEmpty) return false;

    final url = Uri.parse('https://rvhhpqvm-5000.inc1.devtunnels.ms/qr/student/verify_qr'); // Updated URL

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"qr_code": qrCode}),
    );

    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);
      if (mounted) { // Add mounted check before using BuildContext
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? 'QR Verified')),
        );
      }
      return true; // QR is valid, proceed to face scan
    } else {
      if (mounted) { // Add mounted check before using BuildContext
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('QR Verification Failed ❌')),
        );
      }
      return false; // QR verification failed
    }
  }

  @override
  void dispose() {
    // Remove the call to controller?.dispose() as it is no longer necessary
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Student Dashboard')),
      body: Column(
        children: [
          Expanded(
            flex: 5,
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: Text(
                scannedData,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
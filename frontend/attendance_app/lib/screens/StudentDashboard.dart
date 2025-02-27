import 'package:flutter/material.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'FaceScanScreen.dart'; // Import the face recognition screen

class StudentDashboard extends StatefulWidget {
  @override
  _StudentDashboardState createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  String scannedData = "Scan a QR Code";

  void _onQRViewCreated(QRViewController qrController) {
    controller = qrController;
    controller!.scannedDataStream.listen((scanData) async {
      setState(() {
        scannedData = scanData.code ?? "Invalid QR Code";
      });

      // Validate QR Code with backend
      bool isValid = await _sendQRToBackend(scanData.code ?? "");
      
      if (isValid) {
        // Navigate to FaceScanScreen for face recognition
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FaceScanScreen(qrCode: scanData.code ?? ""),
          ),
        );
      }
    });
  }

  Future<bool> _sendQRToBackend(String qrCode) async {
    if (qrCode.isEmpty) return false;

    final url = Uri.parse('http://your-backend-url/validate_qr');
    // Trish update the URL for backend QR validation

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"qr_code": qrCode}),
    );

    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? 'QR Verified')),
      );
      return true; // QR is valid, proceed to face scan
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('QR Verification Failed ❌')),
      );
      return false; // QR verification failed
    }
  }

  @override
  void dispose() {
    controller?.dispose();
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

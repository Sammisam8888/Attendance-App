import 'package:flutter/material.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';
import 'face_scan_view.dart'; // Import the face recognition screen
import 'package:http/http.dart' as http;
import 'dart:convert';

class QRScanScreen extends StatefulWidget {
  @override
  _QRScanScreenState createState() => _QRScanScreenState();
}

class _QRScanScreenState extends State<QRScanScreen> {
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

      if (!mounted) return;

      if (isValid) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('QR Verified'),
            duration: Duration(seconds: 5),
          ),
        );
        await Future.delayed(Duration(seconds: 5));
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => FaceScanScreen(qrCode: scanData.code ?? ""),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('QR Verification Failed ❌'),
            duration: Duration(seconds: 5),
          ),
        );
      }
    });
  }

  Future<bool> _sendQRToBackend(String qrCode) async {
    if (qrCode.isEmpty) return false;

    final url = Uri.parse('https://vv861fqc-5000.inc1.devtunnels.ms/qr/student/verify_qr/$qrCode');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
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
      appBar: AppBar(title: Text('Scan QR Code')),
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

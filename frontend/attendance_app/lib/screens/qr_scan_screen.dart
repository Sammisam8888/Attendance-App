import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart'; // Updated package
import 'package:http/http.dart' as http;
import 'dart:convert'; // Added for JSON encoding/decoding
import 'face_scan_view.dart';

class QRScanScreen extends StatefulWidget {
  const QRScanScreen({super.key});

  @override
  QRScanScreenState createState() => QRScanScreenState();
}

class QRScanScreenState extends State<QRScanScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  bool isScanning = true;

  @override
  void reassemble() {
    super.reassemble();
    if (controller != null) {
      controller!.pauseCamera();
      Future.delayed(Duration(milliseconds: 200), () {
        controller!.resumeCamera();
      });
    }
  }

  void _onQRViewCreated(QRViewController qrController) {
    setState(() {
      controller = qrController;
    });

    if (!isScanning) return;

    controller!.scannedDataStream.listen((scanData) async {
      if (!isScanning) return;

      setState(() {
        isScanning = false; // Prevent multiple scans
      });

      try {
        String qrToken = scanData.code ?? "";
        bool isValid = await _sendQRToBackend(qrToken);

        if (!mounted) return;

        if (isValid) {
          await _handleValidQR(qrToken);
        } else {
          _handleInvalidQR();
        }
      } catch (e) {
        _showError("Error processing QR code");
      } finally {
        if (mounted) {
          setState(() {
            isScanning = true; // Re-enable scanning
          });
        }
      }
    });
  }

  Future<void> _handleValidQR(String qrCode) async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('QR Verified'), duration: Duration(seconds: 5)),
    );
    await Future.delayed(Duration(seconds: 5));
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => FaceScanScreen(qrCode: qrCode),
        ),
      );
    }
  }

  void _handleInvalidQR() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('QR Verification Failed ❌'), duration: Duration(seconds: 5)),
    );
  }

  Future<bool> _sendQRToBackend(String qrCode) async {
    if (qrCode.isEmpty) return false;

    final url = Uri.parse('https://vv861fqc-5000.inc1.devtunnels.ms/qr/student/verify_qr');
    final payload = jsonEncode({"qr_token": qrCode});

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: payload,
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data["success"] ?? false;
      }
    } catch (e) {
      _showError("Error sending QR code to backend");
    }
    return false;
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  void dispose() {
    controller?.dispose(); // Dispose controller properly
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
                "Scan a QR Code",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:logging/logging.dart'; // Correct import
import 'student_dashboard.dart';
import 'package:http/http.dart' as http;

class FaceScanScreen extends StatefulWidget {
  const FaceScanScreen({super.key, required this.qrCode});

  final String qrCode;
  @override
  FaceScanScreenState createState() => FaceScanScreenState();
}

class FaceScanScreenState extends State<FaceScanScreen> {
  CameraController? _cameraController;
  bool isCapturing = false;
  int imageCount = 0;
  late List<CameraDescription> cameras;
  bool _isCameraPermissionGranted = false;
  final Logger _logger = Logger('FaceScanScreenState'); // Update logger initialization

  Future<void> _initializeCamera() async {
    try {
      cameras = await availableCameras();
      if (cameras.isNotEmpty) {
        // Use the front camera if available
        final frontCamera = cameras.firstWhere(
          (camera) => camera.lensDirection == CameraLensDirection.front,
          orElse: () => cameras.first,
        );
        _cameraController = CameraController(
          frontCamera,
          ResolutionPreset.medium,
        );
        await _cameraController!.initialize();
        if (mounted) setState(() {});
      } else {
        _logger.warning("No cameras found"); // Replace logger.e
      }
    } catch (e) {
      _logger.severe("Camera initialization failed: $e"); // Replace logger.e
    }
  }

  Future<void> _requestCameraPermission() async {
    final status = await Permission.camera.request();
    if (status.isGranted) {
      setState(() {
        _isCameraPermissionGranted = true;
      });
      _initializeCamera();
    } else {
      setState(() {
        _isCameraPermissionGranted = false;
      });
    }
  }

  Future<void> _captureImages() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) return;

    setState(() {
      isCapturing = true;
      imageCount = 0;
    });

    while (isCapturing && imageCount < 30) {
      try {
        final XFile image = await _cameraController!.takePicture();
        await _sendImageToBackend(image);
        if (mounted) {
          setState(() {
            imageCount++;
          });
        }
        await Future.delayed(Duration(milliseconds: 500));
      } catch (e) {
        _logger.severe("Error capturing image: $e"); // Replace logger.e
      }
    }

    if (mounted) {
      setState(() {
        isCapturing = false;
      });
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => StudentDashboard()),
      );
    }
  }

  Future<void> _sendImageToBackend(XFile image) async {
    final url = Uri.parse('https://rvhhpqvm-5000.inc1.devtunnels.ms/student/train'); // Updated URL

    try {
      var request = http.MultipartRequest('POST', url);
      request.files.add(await http.MultipartFile.fromPath('image', image.path));
      var response = await request.send();

      if (response.statusCode == 200) {
        _logger.info("Image uploaded successfully"); // Replace logger.i
      } else {
        _logger.warning("Failed to upload image: ${response.statusCode}"); // Replace logger.e
      }
    } catch (e) {
      _logger.severe("Error sending image to backend: $e"); // Replace logger.e
    }
  }

  @override
  void initState() {
    super.initState();
    _requestCameraPermission(); // Request camera permission on init
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Face Registration')),
      body: _isCameraPermissionGranted
          ? Column(
              children: [
                Expanded(
                  child: _cameraController == null || !_cameraController!.value.isInitialized
                      ? Center(child: CircularProgressIndicator())
                      : CameraPreview(_cameraController!),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: isCapturing ? null : _captureImages,
                  child: Text(isCapturing ? 'Capturing...' : 'Start Face Registration'),
                ),
                SizedBox(height: 20),
                Text("Images Captured: $imageCount / 30"),
              ],
            )
          : Center(
              child: ElevatedButton(
                onPressed: _requestCameraPermission,
                child: Text('Allow Camera Permission'),
              ),
            ),
    );
  }
}
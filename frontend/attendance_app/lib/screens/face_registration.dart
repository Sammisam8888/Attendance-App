import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:logging/logging.dart'; // Correct import
import 'student_dashboard.dart';
import 'package:http/http.dart' as http;

class FaceRegistration extends StatefulWidget {
  const FaceRegistration({super.key});

  @override
  FaceRegistrationScreenState createState() => FaceRegistrationScreenState(); // Update class name
}

class FaceRegistrationScreenState extends State<FaceRegistration> { // Remove leading underscore
  CameraController? _cameraController;
  bool isCapturing = false;
  int imageCount = 0;
  late List<CameraDescription> cameras;
  bool _isCameraPermissionGranted = false;
  final Logger _logger = Logger('FaceRegistrationScreenState'); // Update logger initialization

  Future<void> _initializeCamera() async {
    try {
      cameras = await availableCameras();
      if (cameras.isNotEmpty) {
        final frontCamera = cameras.firstWhere(
          (camera) => camera.lensDirection == CameraLensDirection.front,
          orElse: () => cameras.first,
        );
        _cameraController = CameraController(
          frontCamera,
          ResolutionPreset.medium,
          enableAudio: false,
        );
        await _cameraController!.initialize();
        setState(() {});
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
        setState(() {
          imageCount++;
        });
        await Future.delayed(Duration(milliseconds: 500));
      } catch (e) {
        _logger.severe("Error capturing image: $e"); // Replace logger.e
      }
    }

    setState(() {
      isCapturing = false;
    });

    if (mounted) { // Add mounted check before using BuildContext
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => StudentDashboard()),
      );
    }
  }

  Future<void> _sendImageToBackend(XFile image) async {
    final url = Uri.parse('https://vv861fqc-5000.inc1.devtunnels.ms/student/train'); // Updated URL

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
    _requestCameraPermission();
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
                      : AspectRatio(
                          aspectRatio: 1 / 1,
                          child: ClipRect(
                            child: Transform.scale(
                              scale: _cameraController!.value.aspectRatio / (1 / 1),
                              child: Center(
                                child: CameraPreview(_cameraController!),
                              ),
                            ),
                          ),
                        ),
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
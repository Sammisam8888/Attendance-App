import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'student_dashboard.dart';
import 'package:http/http.dart' as http;

class FaceRegistration extends StatefulWidget {
  const FaceRegistration({super.key});

  @override
  _FaceRegistrationScreenState createState() => _FaceRegistrationScreenState();
}

class _FaceRegistrationScreenState extends State<FaceRegistration> {
  CameraController? _cameraController;
  bool isCapturing = false;
  int imageCount = 0;
  late List<CameraDescription> cameras;
  bool _isCameraPermissionGranted = false;

  Future<void> _initializeCamera() async {
    try {
      cameras = await availableCameras();
      if (cameras.isNotEmpty) {
        _cameraController = CameraController(
          cameras.first,
          ResolutionPreset.medium,
        );
        await _cameraController!.initialize();
        setState(() {});
      } else {
        print("No cameras found");
      }
    } catch (e) {
      print("Camera initialization failed: $e");
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
        print("Error capturing image: $e");
      }
    }

    setState(() {
      isCapturing = false;
    });
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => StudentDashboard()),
    );
  }

  Future<void> _sendImageToBackend(XFile image) async {
    final url = Uri.parse('http://127.0.0.1:5000/student/train'); // Update URL

    try {
      var request = http.MultipartRequest('POST', url);
      request.files.add(await http.MultipartFile.fromPath('image', image.path));
      var response = await request.send();

      if (response.statusCode == 200) {
        print("Image uploaded successfully");
      } else {
        print("Failed to upload image: ${response.statusCode}");
      }
    } catch (e) {
      print("Error sending image to backend: $e");
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

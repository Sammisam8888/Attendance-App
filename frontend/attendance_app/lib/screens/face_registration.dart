import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'student_dashboard.dart';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';

class FaceRegistration extends StatefulWidget {
  const FaceRegistration({super.key});

  @override
  FaceRegistrationScreenState createState() => FaceRegistrationScreenState();
}

class FaceRegistrationScreenState extends State<FaceRegistration> {
  CameraController? _cameraController;
  bool isCapturing = false;
  int imageCount = 0;
<<<<<<< HEAD
  
  final Logger _logger = Logger('FaceRegistrationScreenState'); // not required logger file - experimental

=======
  final Logger _logger = Logger('FaceRegistrationScreenState');
>>>>>>> 697e1adc92334cfc53c04454617885398f909b3a

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isNotEmpty) {
        _cameraController = CameraController(
          cameras.first,
          ResolutionPreset.medium,
        );
        await _cameraController!.initialize();
        setState(() {});
      } else {
<<<<<<< HEAD
        _logger.warning("No cameras found"); //experimental
        // print("No cameras found");
      }
    } catch (e) {
      _logger.severe("Camera initialization failed: $e"); //experimental
      // print("Camera initialization failed: $e");
=======
        _logger.warning("No cameras found");
      }
    } catch (e) {
      _logger.severe("Camera initialization failed: $e");
>>>>>>> 697e1adc92334cfc53c04454617885398f909b3a
    }
  }

  Future<void> _captureImages() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) return;

    isCapturing = true;
    imageCount = 0;

    while (isCapturing && imageCount < 30) {
      try {
        final XFile image = await _cameraController!.takePicture();
        await _sendImageToBackend(image);
        imageCount++;
        await Future.delayed(Duration(milliseconds: 500));
      } catch (e) {
        _logger.severe("Error capturing image: $e");
      }
    }

    isCapturing = false;
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => StudentDashboard()),
      );
    }
  }

  Future<void> _sendImageToBackend(XFile image) async {
    final url = Uri.parse('http://your-backend-url/student/upload_face'); 
    //Trish  Update backend URL

    try {
      var request = http.MultipartRequest('POST', url);
      request.files.add(await http.MultipartFile.fromPath('image', image.path));
      var response = await request.send();

      if (response.statusCode == 200) {
<<<<<<< HEAD
        // print("Image uploaded successfully");
        _logger.info("Image uploaded successfully");
      } else {
        // print("Failed to upload image: ${response.statusCode}");
        _logger.warning("Failed to upload image: ${response.statusCode}");
      }
    } catch (e) {
      // print("Error sending image to backend: $e");
=======
        _logger.info("Image uploaded successfully");
      } else {
        _logger.warning("Failed to upload image: ${response.statusCode}");
      }
    } catch (e) {
>>>>>>> 697e1adc92334cfc53c04454617885398f909b3a
      _logger.severe("Error sending image to backend: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    _initializeCamera();
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
      body: Column(
        children: [
          Expanded(
            child: _cameraController == null || !_cameraController!.value.isInitialized
                ? Center(child: CircularProgressIndicator())
                : CameraPreview(_cameraController!),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: _captureImages,
            child: Text('Start Face Registration'),
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }
}

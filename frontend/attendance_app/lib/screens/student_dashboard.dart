import 'package:flutter/material.dart';
import 'package:logging/logging.dart'; // Add this import
import 'qr_scan_screen.dart'; // Import the QR scan screen
import 'face_registration.dart'; // Import the face registration screen

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key}); // Convert 'key' to a super parameter

  @override
  StudentDashboardState createState() => StudentDashboardState();
}

class StudentDashboardState extends State<StudentDashboard> {
  final Logger logger = Logger('StudentDashboard'); // Add this line

  //Sample data 
  String studentName = "John Doe"; // Example student name
  List<Map<String, String>> attendedClasses = [
    {"subject": "Math", "teacher": "Mr. Smith", "time": "9:00 AM - 10:00 AM"},
    {"subject": "Science", "teacher": "Mrs. Johnson", "time": "10:00 AM - 11:00 AM"},
  ]; // Example list of attended classes

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
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Hello, $studentName',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => QRScanScreen(),
                ),
              );
            },
            child: Text('Scan QR Code'),
          ),
          ElevatedButton(
            onPressed: () {
              // Navigate to face registration screen
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FaceRegistration(),
                ),
              );
            },
            child: Text('Register Face'),
          ),
          Expanded(
            flex: 3,
            child: ListView.builder(
              itemCount: attendedClasses.length,
              itemBuilder: (context, index) {
                final classInfo = attendedClasses[index];
                return ListTile(
                  title: Text(classInfo['subject']!),
                  subtitle: Text('${classInfo['teacher']} - ${classInfo['time']}'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
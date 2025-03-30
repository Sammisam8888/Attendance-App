import 'package:flutter/material.dart';
import 'qr_scan_screen.dart'; // Import the QR scan screen
import 'face_registration.dart'; // Import the face registration screen

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  StudentDashboardState createState() => StudentDashboardState(); // Updated to use the public class
}

class StudentDashboardState extends State<StudentDashboard> { // Made public
  String studentName = "John Doe"; // Example student name
  List<Map<String, String>> attendedClasses = [];

  @override
  void initState() {
    super.initState();
    _initializeSampleData();
  }

  void _initializeSampleData() {
    setState(() {
      attendedClasses = [
        {
          'subject': 'Mathematics',
          'teacher': 'Mr. Smith',
          'time': '10:00 AM',
          'subjectCode': 'MATH101',
        },
        {
          'subject': 'Physics',
          'teacher': 'Dr. Johnson',
          'time': '12:00 PM',
          'subjectCode': 'PHYS201',
        },
        // Add more sample data as needed
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Student Dashboard'),
        elevation: 4.0, // Add shadow
        shadowColor: const Color.fromARGB(127, 0, 0, 0), // 127 is 50% opacity
      ),
      body: SingleChildScrollView(
        child: Column(
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
            SizedBox(
              height: 200,
              child: ListView.builder(
                itemCount: attendedClasses.length,
                itemBuilder: (context, index) {
                  final classInfo = attendedClasses[index];
                  return ListTile(
                    title: Text("${classInfo['subject']} (${classInfo['subjectCode']})"), // Display subject code
                    subtitle: Text('${classInfo['teacher']} - ${classInfo['time']}'),
                    trailing: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => QRScanScreen(),
                          ),
                        );
                      },
                      child: Text('Scan QR'),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
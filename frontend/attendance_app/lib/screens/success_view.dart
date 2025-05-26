import 'package:flutter/material.dart';

class SuccessScreen extends StatelessWidget {
  final String subject; // Subject for which attendance is registered
  final String subjectCode; // Add subject code

  const SuccessScreen({super.key, required this.subject, required this.subjectCode}); // Add subject code

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Attendance Success'),
        elevation: 4.0, // Add shadow
        shadowColor: const Color.fromARGB(127, 0, 0, 0), // 127 is 50% opacity
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/login'); // Redirect to login page
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 100),
            SizedBox(height: 20),
            Text(
              "Attendance registered successfully!",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              "Subject: $subject",
              style: TextStyle(fontSize: 16),
            ),
            Text(
              "Subject Code: $subjectCode",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.popUntil(context, ModalRoute.withName('/'));
              },
              child: Text("Back to Dashboard"),
            ),
          ],
        ),
      ),
    );
  }
}
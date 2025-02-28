import 'package:flutter/material.dart';

class SuccessScreen extends StatelessWidget {
  final String subject; // Subject for which attendance is registered

<<<<<<< HEAD
const SuccessScreen({super.key, required this.subject}); // Convert 'key' to a super parameter
=======
  const SuccessScreen({super.key, required this.subject}); // Convert 'key' to a super parameter
>>>>>>> 697e1adc92334cfc53c04454617885398f909b3a

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Attendance Success')),
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

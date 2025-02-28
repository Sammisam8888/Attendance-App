import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

class TeacherDashboard extends StatefulWidget {
  @override
  _TeacherDashboardState createState() => _TeacherDashboardState();
}

class _TeacherDashboardState extends State<TeacherDashboard> {
  String qrImageUrl = 'http://your-backend-url/generate_qr'; // Update with your backend URL
  List<Map<String, String>> studentList = [];
  Timer? _qrTimer;
  Timer? _attendanceTimer;

  @override
  void initState() {
    super.initState();
    _startQrRefresh();
    _startAttendanceFetch();
  }

  // Auto-refresh the QR image every second
  void _startQrRefresh() {
    _qrTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        qrImageUrl = 'http://your-backend-url/generate_qr?timestamp=${DateTime.now().millisecondsSinceEpoch}';
      });
    });
  }

  // Fetch updated attendance list every 3 seconds
  void _startAttendanceFetch() {
    _attendanceTimer = Timer.periodic(Duration(seconds: 3), (timer) async {
      final url = Uri.parse('http://your-backend-url/get_attendance'); // Update with your backend URL
      try {
        final response = await http.get(url);
        if (response.statusCode == 200) {
          final List<dynamic> data = jsonDecode(response.body)['students'];
          setState(() {
            studentList = data.map((student) {
              return {
                'roll': student['roll_number'].toString(),
                'name': student['name'].toString(),
              };
            }).toList();
          });
        }
      } catch (e) {
        print('Error fetching attendance: $e');
      }
    });
  }

  @override
  void dispose() {
    _qrTimer?.cancel(); // Stop refreshing when the page is closed
    _attendanceTimer?.cancel(); // Stop fetching attendance when closed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Teacher Dashboard')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text("Scan the QR code for attendance", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            Image.network(
              qrImageUrl,
              key: ValueKey(qrImageUrl), // Forces the image to refresh
              width: 200,
              height: 200,
              errorBuilder: (context, error, stackTrace) {
                return Text("Failed to load QR code ❌");
              },
            ),
            SizedBox(height: 20),
            Text("Students Marked Present:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Expanded(
              child: studentList.isEmpty
                  ? Center(child: Text("No students marked present yet."))
                  : ListView.builder(
                      itemCount: studentList.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(studentList[index]['name']!),
                          subtitle: Text("Roll No: ${studentList[index]['roll']}"),
                          leading: Icon(Icons.check_circle, color: Colors.green),
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

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'package:logging/logging.dart';

class TeacherDashboard extends StatefulWidget {
  const TeacherDashboard({super.key}); // Convert 'key' to a super parameter

  @override
  TeacherDashboardState createState() => TeacherDashboardState();
}

class TeacherDashboardState extends State<TeacherDashboard> {
  String qrImageUrl = 'http://127.0.0.1:5000/generate_qr'; // Update with your backend URL
  List<Map<String, String>> studentList = [];
  Timer? _qrTimer;
  Timer? _attendanceTimer;
  final Logger _logger = Logger('TeacherDashboardState');

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
        qrImageUrl = 'http://127.0.0.1:5000/generate_qr?timestamp=${DateTime.now().millisecondsSinceEpoch}';
      });
    });
  }

  // Fetch updated attendance list every 3 seconds
  void _startAttendanceFetch() {
    _attendanceTimer = Timer.periodic(Duration(seconds: 3), (timer) async {
      final url = Uri.parse('http://127.0.0.1:5000/get_attendance'); // Update with your backend URL
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
        _logger.severe('Error fetching attendance: $e');
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

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'package:logging/logging.dart'; // Correct import

class TeacherDashboard extends StatefulWidget {
  const TeacherDashboard({super.key});

  @override
  TeacherDashboardState createState() => TeacherDashboardState();
}

class TeacherDashboardState extends State<TeacherDashboard> {
  String qrImageUrl = 'https://rvhhpqvm-5000.inc1.devtunnels.ms/qr/teacher/get_qr';
  List<Map<String, String>> studentList = [];
  Timer? _qrTimer;
  Timer? _attendanceTimer;
  final Logger _logger = Logger('TeacherDashboardState'); // Update logger initialization

  @override
  void initState() {
    super.initState();
    _startQrRefresh();
    _startAttendanceFetch();
  }

  // Refresh the QR image every 3 seconds
  void _startQrRefresh() {
    _qrTimer = Timer.periodic(Duration(seconds: 3), (timer) {
      setState(() {
        qrImageUrl = 'https://vv861fqc-5000.inc1.devtunnels.ms/qr/teacher/get_qr?timestamp=${DateTime.now().millisecondsSinceEpoch}'; // Updated URL
      });
    });
  }

  // Fetch updated attendance list every 3 seconds
  void _startAttendanceFetch() {
    _attendanceTimer = Timer.periodic(Duration(seconds: 3), (timer) async {
      final url = Uri.parse('https://vv861fqc-5000.inc1.devtunnels.ms/attendance/get_all_attendance'); // Updated URL
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
        _logger.severe('Error fetching attendance: $e'); // Replace logger.e
      }
    });
  }

  @override
  void dispose() {
    _qrTimer?.cancel();
    _attendanceTimer?.cancel();
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
              key: ValueKey(qrImageUrl),
              width: 200,
              height: 200,
              errorBuilder: (context, error, stackTrace) {
                return Text("Failed to load QR code ❌");
              },
            ),
            SizedBox(height: 20),
            Text("Students Marked Present:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            studentList.isEmpty
                ? Center(child: Text("No students marked present yet."))
                : Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columns: [
                          DataColumn(label: Text('Roll No')),
                          DataColumn(label: Text('Name')),
                        ],
                        rows: studentList.map((student) {
                          return DataRow(cells: [
                            DataCell(Text(student['roll']!)),
                            DataCell(Text(student['name']!)),
                          ]);
                        }).toList(),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
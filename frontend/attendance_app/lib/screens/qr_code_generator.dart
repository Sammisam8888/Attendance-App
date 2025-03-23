import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'package:logging/logging.dart';
import 'logger.dart'; // Import the logger and theme toggle
import '../utils/themes.dart'; // Import themes

class QRCodeGenerator extends StatefulWidget {
  final String classId;
  final String subjectCode; // Add subject code

  QRCodeGenerator({required this.classId, required this.subjectCode}); // Add subject code

  @override
  _QRCodeGeneratorState createState() => _QRCodeGeneratorState();
}

class _QRCodeGeneratorState extends State<QRCodeGenerator> with SingleTickerProviderStateMixin {
  String qrImageUrl = '';
  List<Map<String, String>> studentList = [];
  Timer? _qrTimer;
  Timer? _attendanceTimer;
  final Logger _logger = Logger('QRCodeGeneratorState');
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, duration: Duration(milliseconds: 500));
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
    _animationController.forward();
    _startQrRefresh(widget.classId);
    _startAttendanceFetch(widget.classId);
  }

  void _startQrRefresh(String classId) {
    _qrTimer = Timer.periodic(Duration(seconds: 3), (timer) async {
      final response = await http.get(
        Uri.parse('https://vv861fqc-5000.inc1.devtunnels.ms/qr/teacher/get_qr?classId=$classId&subjectCode=${widget.subjectCode}&timestamp=${DateTime.now().millisecondsSinceEpoch}'), // Updated URL
        headers: {
          'Authorization': 'Bearer YOUR_TOKEN_HERE',
        },
      );
      if (response.statusCode == 200) {
        setState(() {
          qrImageUrl = 'https://vv861fqc-5000.inc1.devtunnels.ms/qr/teacher/get_qr?classId=$classId&subjectCode=${widget.subjectCode}&timestamp=${DateTime.now().millisecondsSinceEpoch}';
          _animationController.reset();
          _animationController.forward();
        });
      } else {
        // Handle error
      }
    });
  }

  void _startAttendanceFetch(String classId) {
    _attendanceTimer = Timer.periodic(Duration(seconds: 3), (timer) async {
      final url = Uri.parse('https://vv861fqc-5000.inc1.devtunnels.ms/attendance/get_all_attendance?classId=$classId'); // Updated URL
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
          _updateAttendanceInDatabase(classId, studentList);
        }
      } catch (e) {
        _logger.severe('Error fetching attendance: $e');
      }
    });
  }

  Future<void> _updateAttendanceInDatabase(String classId, List<Map<String, String>> studentList) async {
    final url = Uri.parse('https://rvhhpqvm-5000.inc1.devtunnels.ms/attendance/store_attendance');
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "classId": classId,
          "students": studentList,
        }),
      );
      if (response.statusCode != 200) {
        _logger.warning('Failed to update attendance in database');
      }
    } catch (e) {
      _logger.severe('Error updating attendance in database: $e');
    }
  }

  @override
  void dispose() {
    _qrTimer?.cancel();
    _attendanceTimer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('QR Code Generator'),
        actions: [
          IconButton(
            icon: Icon(Icons.brightness_6),
            onPressed: toggleThemeMode, // Use the toggle function
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              if (qrImageUrl.isNotEmpty) ...[
                Text("Scan the QR code for attendance", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                SizedBox(height: 20),
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Image.network(
                    qrImageUrl,
                    key: ValueKey(qrImageUrl),
                    width: 200,
                    height: 200,
                    errorBuilder: (context, error, stackTrace) {
                      return Text("Failed to load QR code ❌");
                    },
                  ),
                ),
                SizedBox(height: 20),
                Text("Students Marked Present:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                SizedBox(height: 10),
                studentList.isEmpty
                    ? Center(child: Text("No students marked present yet."))
                    : SingleChildScrollView(
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
              ],
            ],
          ),
        ),
      ),
    );
  }
}

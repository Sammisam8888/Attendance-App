// ignore_for_file: unused_field, unused_element

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'package:logging/logging.dart'; // Correct import
import 'qr_code_generator.dart'; // Import the QRCodeGenerator screen
import 'view_details_screen.dart'; // Import the ViewDetailsScreen
import 'package:intl/intl.dart'; // Import for date and time formatting

class TeacherDashboard extends StatefulWidget {
  const TeacherDashboard({super.key});

  @override
  TeacherDashboardState createState() => TeacherDashboardState();
}

class TeacherDashboardState extends State<TeacherDashboard> with SingleTickerProviderStateMixin {
  List<Map<String, String>> studentList = [];
  List<Map<String, String>> classList = [];
  String teacherName = "Teacher"; // Default teacher name
  Timer? _attendanceTimer;
  Timer? _clockTimer;
  String currentTime = ""; // Current time
  final Logger _logger = Logger('TeacherDashboardState'); // Update logger initialization
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, duration: Duration(milliseconds: 500));
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
    _animationController.forward(); // Ensure the animation starts
    _initializeSampleData(); // Initialize sample data
    _initializeTeacherName(); // Initialize sample teacher name
    _startClock(); // Start the clock
  }

  void _startClock() {
    _clockTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        currentTime = DateFormat('hh:mm a').format(DateTime.now());
      });
    });
  }

  void _initializeSampleData() {
    setState(() {
      classList = [
        {
          'classroom': '101',
          'branch': 'Computer Science',
          'semester': '5',
          'subject': 'Data Structures',
          'subjectCode': 'CS201',
          'timing': '09:00 AM',
          'notesLink': 'http://example.com/notes',
        },
        {
          'classroom': '102',
          'branch': 'Electronics',
          'semester': '3',
          'subject': 'Circuit Theory',
          'subjectCode': 'EC101',
          'timing': '11:00 AM',
          'notesLink': 'http://example.com/notes',
        },
        // Add more sample data as needed
      ];
    });
  }

  void _initializeTeacherName() {
    setState(() {
      teacherName = 'Dr. Jane Doe';
    });
  }

  // Fetch updated attendance list every 3 seconds
  void _startAttendanceFetch(String classId) {
    _attendanceTimer = Timer.periodic(Duration(seconds: 3), (timer) async {
      final url = Uri.parse('https://rvhhpqvm-5000.inc1.devtunnels.ms/attendance/get_all_attendance?classId=$classId'); // Updated URL
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
        _logger.severe('Error fetching attendance: $e'); // Replace logger.e
      }
    });
  }

  // Update attendance in the database
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

  void _showAddClassModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String classroom = '';
        String branch = '';
        String semester = '';
        String subject = '';
        String subjectCode = ''; // Add subject code
        String timing = '';
        String notesLink = '';

        return AlertDialog(
          title: Text('Add New Class Schedule'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(labelText: 'Classroom'),
                  onChanged: (value) {
                    classroom = value;
                  },
                ),
                TextField(
                  decoration: InputDecoration(labelText: 'Branch'),
                  onChanged: (value) {
                    branch = value;
                  },
                ),
                TextField(
                  decoration: InputDecoration(labelText: 'Semester'),
                  onChanged: (value) {
                    semester = value;
                  },
                ),
                TextField(
                  decoration: InputDecoration(labelText: 'Subject'),
                  onChanged: (value) {
                    subject = value;
                  },
                ),
                TextField(
                  decoration: InputDecoration(labelText: 'Subject Code'),
                  onChanged: (value) {
                    subjectCode = value;
                  },
                ),
                TextField(
                  decoration: InputDecoration(labelText: 'Timing'),
                  onTap: () async {
                    TimeOfDay? pickedTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (pickedTime != null) {
                      setState(() {
                        timing = pickedTime.format(context);
                      });
                    }
                  },
                  readOnly: true,
                  controller: TextEditingController(text: timing),
                ),
                TextField(
                  decoration: InputDecoration(labelText: 'Notes Link'),
                  onChanged: (value) {
                    notesLink = value;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                setState(() {
                  classList.add({
                    'classroom': classroom,
                    'branch': branch,
                    'semester': semester,
                    'subject': subject,
                    'subjectCode': subjectCode, // Add subject code
                    'timing': timing,
                    'notesLink': notesLink,
                  });
                });
                final response = await http.post(
                  Uri.parse('https://rvhhpqvm-5000.inc1.devtunnels.ms/store_class_schedule'),
                  headers: {"Content-Type": "application/json"},
                  body: jsonEncode({
                    'classroom': classroom,
                    'branch': branch,
                    'semester': semester,
                    'subject': subject,
                    'subject_code': subjectCode, // Add subject code
                    'timing': timing,
                    'notes_link': notesLink,
                  }),
                );
                if (response.statusCode == 200) {
                  Navigator.of(context).pop();
                } else {
                  // Handle error
                }
              },
              child: Text('Add'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _attendanceTimer?.cancel();
    _clockTimer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Teacher Dashboard'),
        actions: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: ElevatedButton(
              onPressed: () => _showAddClassModal(context),
              child: Row(
                children: [
                  Icon(Icons.add),
                  SizedBox(width: 4),
                  Text('Add Class'),
                ],
              ),
              style: ElevatedButton.styleFrom(
                foregroundColor: Theme.of(context).primaryColor,
                backgroundColor: Colors.white,
                shadowColor: Colors.black.withOpacity(0.2),
                elevation: 3,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text("Hello, $teacherName!", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              SizedBox(height: 20),
              Text("Today's Classes:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Text("Current Time: $currentTime", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)), // Display current time
              SizedBox(height: 10),
              ...classList.map((classInfo) {
                return Card(
                  child: ListTile(
                    title: Text("${classInfo['subject']} (${classInfo['subjectCode']}) - ${classInfo['branch']} - Semester ${classInfo['semester']}"), // Display subject code
                    subtitle: Text("Classroom: ${classInfo['classroom']} | Timing: ${classInfo['timing']}"),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => QRCodeGenerator(classId: classInfo['classroom']!, subjectCode: classInfo['subjectCode']!), // Add subject code
                              ),
                            );
                          },
                          child: Text("Activate QR"),
                        ),
                        SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ViewDetailsScreen(classId: classInfo['classroom']!, subjectCode: classInfo['subjectCode']!), // Add subject code
                              ),
                            );
                          },
                          child: Text("View Details"),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ],
          ),
        ),
      ),
    );
  }
}
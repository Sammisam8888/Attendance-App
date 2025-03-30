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
        String block = '';
        String floor = '';
        String roomNumber = '';
        String branch = '';
        String semester = '';
        String subjectCode = ''; // Add subject code
        String startTime = ''; // Change timing to startTime
        String notesLink = '';
        TextEditingController timeController = TextEditingController(); // Add controller for time input

        return AlertDialog(
          title: Text('Add New Class Schedule'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                Text('Classroom', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)), // Add heading
                SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        decoration: InputDecoration(labelText: 'Block'),
                        items: ['A', 'B', 'C', 'D'].map((block) {
                          return DropdownMenuItem(
                            value: block,
                            child: Text(block),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            block = value!;
                          });
                        },
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        decoration: InputDecoration(labelText: 'Floor'),
                        items: ['Ground', '1st', '2nd'].map((floor) {
                          return DropdownMenuItem(
                            value: floor,
                            child: Text(floor),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            floor = value!;
                          });
                        },
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        decoration: InputDecoration(labelText: 'Room Number'),
                        items: (floor == 'Ground'
                            ? List.generate(50, (index) => (101 + index).toString())
                            : floor == '1st'
                                ? List.generate(50, (index) => (201 + index).toString())
                                : List.generate(50, (index) => (301 + index).toString()))
                            .map((room) {
                          return DropdownMenuItem(
                            value: room,
                            child: Text(room),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            roomNumber = value!;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                TextField(
                  decoration: InputDecoration(labelText: 'Branch'),
                  onChanged: (value) {
                    branch = value;
                  },
                ),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(labelText: 'Semester'),
                    items: ['1st', '2nd', '3rd', '4th', '5th', '6th', '7th', '8th'].map((sem) {
                      return DropdownMenuItem(
                        value: sem,
                        child: Text(sem),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        semester = value!;
                      });
                    },
                  ),
                ),
                TextField(
                  decoration: InputDecoration(labelText: 'Subject Code'),
                  onChanged: (value) {
                    subjectCode = value;
                  },
                ),
                TextField(
                  decoration: InputDecoration(labelText: 'Start Time'),
                  onTap: () async {
                    TimeOfDay? pickedTime = await showTimePicker(
                      context: dialogContext,
                      initialTime: TimeOfDay.now(),
                    );
                    if (pickedTime != null && mounted) {
                      setState(() {
                        timing = pickedTime.format(dialogContext);
                      });
                    }
                  },
                  readOnly: true,
                  controller: timeController, // Use the controller
                ),
                TextField(
                  decoration: InputDecoration(labelText: 'Notes Link (Optional)'),
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
                    'classroom': '$block$roomNumber',
                    'branch': branch,
                    'semester': semester,
                    'subjectCode': subjectCode, // Add subject code
                    'timing': startTime, // Change timing to startTime
                    'notesLink': notesLink,
                  });
                }

                final response = await http.post(
                  Uri.parse('https://rvhhpqvm-5000.inc1.devtunnels.ms/store_class_schedule'),
                  headers: {"Content-Type": "application/json"},
                  body: jsonEncode({
                    'classroom': '$block$roomNumber',
                    'branch': branch,
                    'semester': semester,
                    'subject_code': subjectCode, // Add subject code
                    'timing': startTime, // Change timing to startTime
                    'notes_link': notesLink,
                  }),
                );

                if (response.statusCode == 200 && dialogContext.mounted) {
                  Navigator.of(dialogContext).pop();
                } else {
                  // Handle error
                }
              },
              child: Text('Add'),
            ),
            TextButton(
              onPressed: () {
                if (dialogContext.mounted) {
                  Navigator.of(dialogContext).pop();
                }
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
        elevation: 4.0, // Add shadow
        shadowColor: Colors.black.withOpacity(0.5), // Customize shadow color
        actions: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: Theme.of(context).primaryColor,
                backgroundColor: Colors.white,
                shadowColor: Colors.black.withAlpha((0.2 * 255).toInt()),
                elevation: 3,
              ),
              child: Row(
                children: [
                  Icon(Icons.add),
                  SizedBox(width: 4),
                  Text('Add Class'),
                ],
              ),
              onPressed: () => _showAddClassModal(context),
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
                          child: Text("Activate QR"),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => QRCodeGenerator(classId: classInfo['classroom']!, subjectCode: classInfo['subjectCode']!), // Add subject code
                              ),
                            );
                          },
                        ),
                        SizedBox(width: 8),
                        ElevatedButton(
                          child: Text("View Details"),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ViewDetailsScreen(classId: classInfo['classroom']!, subjectCode: classInfo['subjectCode']!), // Add subject code
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
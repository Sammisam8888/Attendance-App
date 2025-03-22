import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:logging/logging.dart';

class ViewDetailsScreen extends StatefulWidget {
  final String classId;
  final String subjectCode; // Add subject code

  const ViewDetailsScreen({super.key, required this.classId, required this.subjectCode}); // Add subject code

  @override
  _ViewDetailsScreenState createState() => _ViewDetailsScreenState();
}

class _ViewDetailsScreenState extends State<ViewDetailsScreen> {
  final Logger _logger = Logger('ViewDetailsScreen');
  Map<String, dynamic>? classDetails;

  @override
  void initState() {
    super.initState();
    _fetchClassDetails();
  }

  Future<void> _fetchClassDetails() async {
    final url = Uri.parse('https://rvhhpqvm-5000.inc1.devtunnels.ms/class_details?classId=${widget.classId}&subjectCode=${widget.subjectCode}'); // Add subject code
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          classDetails = jsonDecode(response.body);
        });
      } else {
        _logger.warning('Failed to fetch class details');
      }
    } catch (e) {
      _logger.severe('Error fetching class details: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Class Details')),
      body: classDetails == null
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Classroom: ${classDetails!['classroom']}", style: TextStyle(fontSize: 18)),
                  Text("Branch: ${classDetails!['branch']}", style: TextStyle(fontSize: 18)),
                  Text("Semester: ${classDetails!['semester']}", style: TextStyle(fontSize: 18)),
                  Text("Subject: ${classDetails!['subject']}", style: TextStyle(fontSize: 18)),
                  Text("Timing: ${classDetails!['timing']}", style: TextStyle(fontSize: 18)),
                  Text("Notes Link: ${classDetails!['notesLink']}", style: TextStyle(fontSize: 18)),
                  Text("Subject Code: ${classDetails!['subjectCode']}", style: TextStyle(fontSize: 18)), // Add subject code
                ],
              ),
            ),
    );
  }
}

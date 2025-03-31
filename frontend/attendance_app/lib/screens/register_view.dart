import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'login_view.dart';
import 'package:logging/logging.dart'; // Add this import

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key}); // Convert 'key' to a super parameter

  @override
  RegisterScreenState createState() => RegisterScreenState();
}

class RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController(); // Add this line
  final _idController = TextEditingController(); // Will hold Roll No or Teacher ID
  final _branchController = TextEditingController(); // Add this line
  final _semesterController = TextEditingController(); // Add this line
  final _subjectSpecialisationController = TextEditingController(); // Add this line
  final _assignedClassesController = TextEditingController(); // Add this line
  final _subjectCodeController = TextEditingController(); // Add this line
  String _role = 'Student'; // Default role
  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;
  final Logger logger = Logger('RegisterScreen'); // Add this line

  Future<void> _register() async {
    if (_passwordController.text.trim() != _confirmPasswordController.text.trim()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Passwords do not match ❌")),
      );
      return;
    }

    final url = Uri.parse(_role == 'Teacher' 
        ? 'https://rvhhpqvm-5000.inc1.devtunnels.ms/auth/teacher/signup'
        : 'https://rvhhpqvm-5000.inc1.devtunnels.ms/auth/student/signup');

    final body = {
      "name": _nameController.text.trim(),
      "email": _emailController.text.trim(),
      "password": _passwordController.text.trim(),
      _role == 'Teacher' ? "teacher_id" : "roll_number": _idController.text.trim(),
    };

    if (_role == 'Student') {
      body["branch"] = _branchController.text.trim();
      body["semester"] = _semesterController.text.trim();
      body["subject_code"] = _subjectCodeController.text.trim(); // Add this line
    } else {
      body["subject_specialisation"] = _subjectSpecialisationController.text.trim();
      body["assigned_classes"] = _assignedClassesController.text.trim();
    }

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );

    final result = jsonDecode(response.body);
    if (response.statusCode == 201) {
      if (!mounted) return; // Add this check before using BuildContext
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result["message"] ?? "Registration Successful ✅")),
      );
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        ); // Navigate back to login after successful registration
      }
    } else {
      if (!mounted) return; // Add this check before using BuildContext
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result["message"] ?? "Registration Failed ❌")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Register'),
        elevation: 4.0, // Add shadow
        shadowColor: const Color.fromARGB(127, 0, 0, 0), // 127 is 50% opacity
      ),
      body: SingleChildScrollView( // Wrap the body in SingleChildScrollView
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag, // Dismiss keyboard on scroll
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              SizedBox(height: 50), // Add some space at the top

              ExpansionTile(
                title: Text('Select Role: $_role'),
                children: ['Teacher', 'Student'].map((String choice) {
                  return ListTile(
                    title: Text(choice),
                    onTap: () {
                      setState(() {
                        _role = choice;
                      });
                    },
                  );
                }).toList(),
              ),

              TextField(controller: _nameController, decoration: InputDecoration(labelText: 'Full Name')),
              TextField(controller: _emailController, decoration: InputDecoration(labelText: 'Email')),

              // Password Field with Show/Hide Toggle
              TextField(
                controller: _passwordController,
                obscureText: !_passwordVisible,
                decoration: InputDecoration(
                  labelText: 'Password',
                  suffixIcon: IconButton(
                    icon: Icon(_passwordVisible ? Icons.visibility : Icons.visibility_off),
                    onPressed: () {
                      setState(() { _passwordVisible = !_passwordVisible; });
                    },
                  ),
                ),
              ),

              // Confirm Password Field with Show/Hide Toggle
              TextField(
                controller: _confirmPasswordController,
                obscureText: !_confirmPasswordVisible,
                decoration: InputDecoration(
                  labelText: 'Confirm Password',
                  suffixIcon: IconButton(
                    icon: Icon(_confirmPasswordVisible ? Icons.visibility : Icons.visibility_off),
                    onPressed: () {
                      setState(() { _confirmPasswordVisible = !_confirmPasswordVisible; });
                    },
                  ),
                ),
              ),

              // TextField for Roll Number or Teacher ID
              TextField(
                controller: _idController,
                decoration: InputDecoration(
                  labelText: _role == 'Teacher' ? 'Teacher ID' : 'Roll Number',
                  hintText: _role == 'Teacher' ? 'Enter Teacher ID' : 'Enter Roll Number',
                ),
              ),

              if (_role == 'Student') ...[
                TextField(controller: _branchController, decoration: InputDecoration(labelText: 'Branch')),
                TextField(controller: _semesterController, decoration: InputDecoration(labelText: 'Semester')),
                TextField(controller: _subjectCodeController, decoration: InputDecoration(labelText: 'Subject Code')), // Add this line
              ],

              if (_role == 'Teacher') ...[
                TextField(controller: _subjectSpecialisationController, decoration: InputDecoration(labelText: 'Subject Specialisation')),
                TextField(controller: _assignedClassesController, decoration: InputDecoration(labelText: 'Assigned Classes')),
              ],

              SizedBox(height: 20),
              ElevatedButton(onPressed: _register, child: Text('Register')),
              SizedBox(height: 20), // Add some space at the bottom
            ],
          ),
        ),
      ),
    );
  }
}
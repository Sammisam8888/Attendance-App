import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'teacher_dashboard.dart';
import 'student_dashboard.dart';
import 'register_view.dart';
import 'package:logging/logging.dart'; // Add this import

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _rollNoController = TextEditingController(); // Add this line
  String _role = '';
  bool _isLoading = false;
  bool _passwordVisible = false; // Password visibility toggle
  final Logger logger = Logger('LoginScreen'); // Add this line

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
    });

    final String loginEndpoint = _role == 'Teacher'
        ? 'https://rvhhpqvm-5000.inc1.devtunnels.ms/auth/teacher/login'  // Updated URL
        : 'https://rvhhpqvm-5000.inc1.devtunnels.ms/auth/student/login'; // Updated URL

    final body = {
      "email": _emailController.text.trim(),
      "password": _passwordController.text.trim(),
    };

    if (_role == 'Student') {
      body["roll_no"] = _rollNoController.text.trim(); // Add this line
    }

    final response = await http.post(
      Uri.parse(loginEndpoint),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );

    final result = jsonDecode(response.body);

    setState(() {
      _isLoading = false;
    });

    if (!mounted) return;

    if (response.statusCode == 200) {
      _showAlertDialog("Success", result["message"] ?? "Login Successful ✅", true);
    } else {
      _showAlertDialog("Error", result["message"] ?? "Login Failed ❌", false);
    }
  }

  void _showAlertDialog(String title, String message, bool isSuccess) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                if (isSuccess) {
                  if (_role == 'Teacher') {
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => TeacherDashboard()));
                  } else {
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => StudentDashboard()));
                  }
                }
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }

  void _showRoleSelection() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Role'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: ['Teacher', 'Student'].map((String choice) {
              return ListTile(
                title: Text(choice),
                onTap: () {
                  setState(() {
                    _role = choice;
                  });
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag, // Dismiss keyboard on scroll
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 50), // Add some space at the top
              TextField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
              ),
              TextField(
                controller: _passwordController,
                obscureText: !_passwordVisible,
                decoration: InputDecoration(
                  labelText: 'Password',
                  suffixIcon: IconButton(
                    icon: Icon(_passwordVisible ? Icons.visibility : Icons.visibility_off),
                    onPressed: () {
                      setState(() {
                        _passwordVisible = !_passwordVisible;
                      });
                    },
                  ),
                ),
              ),
              if (_role == 'Student') // Add this block
                TextField(
                  controller: _rollNoController,
                  decoration: InputDecoration(labelText: 'Roll Number'),
                ),
              ListTile(
                title: Text('Role: $_role'),
                trailing: Icon(Icons.arrow_drop_down),
                onTap: _showRoleSelection,
              ),
              SizedBox(height: 20),
              _isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton(onPressed: _login, child: Text('Login')),
              TextButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => RegisterScreen()));
                },
                child: Text('New user? Register here'),
              ),
              SizedBox(height: 20), // Add some space at the bottom
            ],
          ),
        ),
      ),
    );
  }
}
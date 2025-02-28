import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'teacher_dashboard.dart';
import 'student_dashboard.dart';
import 'register_view.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key}); // Convert 'key' to a super parameter

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _role = 'Student'; // Default role
  bool _isLoading = false; // Loading indicator

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
    });

    final String loginEndpoint = _role == 'Teacher'
        ? 'http://your-backend-url/teacher/login'  // Backend endpoint for teachers
        : 'http://your-backend-url/student/login'; // Backend endpoint for students

    final response = await http.post(
      Uri.parse(loginEndpoint),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": _emailController.text.trim(),
        "password": _passwordController.text.trim(),
      }),
    );

    final result = jsonDecode(response.body);

    setState(() {
      _isLoading = false;
    });

    if (!mounted) return; // Add this check before using BuildContext

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result["message"] ?? "Login Successful ✅")),
      );

      if (mounted) {
        if (_role == 'Teacher') {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => TeacherDashboard()));
        } else {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => StudentDashboard()));
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result["message"] ?? "Login Failed ❌")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            DropdownButton<String>(
              value: _role,
              onChanged: (String? newValue) {
                setState(() {
                  _role = newValue!;
                });
              },
              items: ['Teacher', 'Student'].map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
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
          ],
        ),
      ),
    );
  }
}

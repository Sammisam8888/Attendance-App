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
<<<<<<< HEAD
  bool _passwordVisible = false; // Password visibility toggle
=======
>>>>>>> 697e1adc92334cfc53c04454617885398f909b3a

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

<<<<<<< HEAD
            _isLoading = false;
    }

    if (!mounted) return; // Add this check before using BuildContext

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result["message"] ?? "Login Successful ✅")),
      );

=======
>>>>>>> 697e1adc92334cfc53c04454617885398f909b3a
      if (mounted) {
        if (_role == 'Teacher') {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => TeacherDashboard()));
        } else {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => StudentDashboard()));
        }
      }
<<<<<<< HEAD
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
=======
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result["message"] ?? "Login Failed ❌")),
      );
    }
>>>>>>> 697e1adc92334cfc53c04454617885398f909b3a
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
<<<<<<< HEAD
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
=======
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
>>>>>>> 697e1adc92334cfc53c04454617885398f909b3a
        ),
      ),
    );
  }
<<<<<<< HEAD
};
=======
}
>>>>>>> 697e1adc92334cfc53c04454617885398f909b3a

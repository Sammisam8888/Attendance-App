import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'LoginScreen.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _idController = TextEditingController(); // Will hold Roll No or Teacher ID
  String _role = 'Student'; // Default role
  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;

  Future<void> _register() async {
    if (_passwordController.text.trim() != _confirmPasswordController.text.trim()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Passwords do not match ❌")),
      );
      return;
    }

    final url = Uri.parse(_role == 'Teacher' 
        ? 'http://your-backend-url/teacher/signup' 
        : 'http://your-backend-url/student/signup'); // Update backend URLs

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "name": _nameController.text.trim(),
        "email": _emailController.text.trim(),
        "password": _passwordController.text.trim(),
        _role == 'Teacher' ? "teacher_id" : "roll_number": _idController.text.trim(),
      }),
    );

    final result = jsonDecode(response.body);
    if (response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result["message"] ?? "Registration Successful ✅")),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result["message"] ?? "Registration Failed ❌")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Register')),
      body: SingleChildScrollView(
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

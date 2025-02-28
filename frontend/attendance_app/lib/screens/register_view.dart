import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
<<<<<<< HEAD
import 'login_view.dart';

class RegisterScreen extends StatefulWidget {
=======

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key}); // Convert 'key' to a super parameter

>>>>>>> 697e1adc92334cfc53c04454617885398f909b3a
  @override
  RegisterScreenState createState() => RegisterScreenState();
}

class RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
<<<<<<< HEAD
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
=======
  final _rollNumberController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> _register() async {
    final url = Uri.parse('http://your-backend-url/student/signup'); // Update with your backend URL
>>>>>>> 697e1adc92334cfc53c04454617885398f909b3a

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "name": _nameController.text.trim(),
<<<<<<< HEAD
        "email": _emailController.text.trim(),
        "password": _passwordController.text.trim(),
        _role == 'Teacher' ? "teacher_id" : "roll_number": _idController.text.trim(),
=======
        "roll_number": _rollNumberController.text.trim(),
        "email": _emailController.text.trim(),
        "password": _passwordController.text.trim(),
>>>>>>> 697e1adc92334cfc53c04454617885398f909b3a
      }),
    );

    final result = jsonDecode(response.body);
<<<<<<< HEAD

    if (response.statusCode == 201) {
      if (!mounted) return; 
      // Add this check before using BuildContext
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result["message"] ?? "Registration Successful ✅")),
      );

      if (mounted) {
        Navigator.pop(context); // Navigate back to login after successful registration
      }

=======
    if (response.statusCode == 201) {
      if (!mounted) return; // Add this check before using BuildContext
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result["message"] ?? "Registration Successful ✅")),
      );
      if (mounted) {
        Navigator.pop(context); // Navigate back to login after successful registration
      }
>>>>>>> 697e1adc92334cfc53c04454617885398f909b3a
    } else {
      if (!mounted) return; // Add this check before using BuildContext
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result["message"] ?? "Registration Failed ❌")),
      );
<<<<<<< HEAD
=======
    }
  }
>>>>>>> 697e1adc92334cfc53c04454617885398f909b3a

  @override
  Widget build(BuildContext context) {
    return Scaffold(
<<<<<<< HEAD
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
=======
      appBar: AppBar(title: Text('Student Registration')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: _nameController, decoration: InputDecoration(labelText: 'Name')),
            TextField(controller: _rollNumberController, decoration: InputDecoration(labelText: 'Roll Number')),
            TextField(controller: _emailController, decoration: InputDecoration(labelText: 'Email')),
            TextField(controller: _passwordController, decoration: InputDecoration(labelText: 'Password'), obscureText: true),
            SizedBox(height: 20),
            ElevatedButton(onPressed: _register, child: Text("Register")),
          ],
>>>>>>> 697e1adc92334cfc53c04454617885398f909b3a
        ),
      ),
    );
  }
}

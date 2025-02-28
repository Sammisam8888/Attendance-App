import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key}); // Convert 'key' to a super parameter

  @override
  RegisterScreenState createState() => RegisterScreenState();
}

class RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _rollNumberController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> _register() async {
    final url = Uri.parse('http://127.0.0.1:5000/student/signup'); // Update with your backend URL

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "name": _nameController.text.trim(),
        "roll_number": _rollNumberController.text.trim(),
        "email": _emailController.text.trim(),
        "password": _passwordController.text.trim(),
      }),
    );

    final result = jsonDecode(response.body);
    if (response.statusCode == 201) {
      if (!mounted) return; // Add this check before using BuildContext
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result["message"] ?? "Registration Successful ✅")),
      );
      if (mounted) {
        Navigator.pop(context); // Navigate back to login after successful registration
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
        ),
      ),
    );
  }
}

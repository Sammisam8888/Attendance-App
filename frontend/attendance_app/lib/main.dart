import 'package:flutter/material.dart';
import 'screens/LoginScreen.dart';
import 'screens/RegisterScreen.dart';
import 'screens/TeacherDashboard.dart';
import 'screens/StudentDashboard.dart';
import 'screens/FaceRegistration.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Attendance App',
      initialRoute: '/',
      routes: {
        '/': (context) => LoginScreen(),
        '/register': (context) => RegisterScreen(),
        '/teacher_dashboard': (context) => TeacherDashboard(),
        '/student_dashboard': (context) => StudentDashboard(),
        '/face_registration': (context) => FaceRegistration(),
      },
    );
  }
}

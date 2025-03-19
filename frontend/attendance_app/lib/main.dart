import 'package:flutter/material.dart';
import 'screens/login_view.dart';
import 'screens/register_view.dart';
import 'screens/teacher_dashboard.dart';
import 'screens/student_dashboard.dart';
import 'screens/face_registration.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
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
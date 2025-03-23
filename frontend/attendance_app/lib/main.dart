import 'package:flutter/material.dart';
import 'screens/login_view.dart';
import 'screens/register_view.dart';
import 'screens/teacher_dashboard.dart';
import 'screens/student_dashboard.dart';
import 'screens/face_registration.dart';
import 'screens/logger.dart'; // Import the logger and theme toggle
import 'utils/themes.dart'; // Import themes

void main() {
  setupLogger();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, ThemeMode currentMode, __) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Attendance App',
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: currentMode,
          initialRoute: '/',
          routes: {
            '/': (context) => LoginScreen(),
            '/register': (context) => RegisterScreen(),
            '/teacher_dashboard': (context) => TeacherDashboard(),
            '/student_dashboard': (context) => StudentDashboard(),
            '/face_registration': (context) => FaceRegistration(),
          },
        );
      },
    );
  }
}
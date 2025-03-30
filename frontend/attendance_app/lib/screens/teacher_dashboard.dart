import 'package:flutter/material.dart';

class TeacherDashboard extends StatelessWidget {
  const TeacherDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Teacher Dashboard'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16.0,
          mainAxisSpacing: 16.0,
          children: [
            _buildDashboardCard('Students', Icons.people, () {
              Navigator.pushNamed(context, '/students');
            }),
            _buildDashboardCard('Attendance', Icons.check, () {
              Navigator.pushNamed(context, '/attendance');
            }),
            _buildDashboardCard('Assignments', Icons.assignment, () {
              Navigator.pushNamed(context, '/assignments');
            }),
            _buildDashboardCard('Reports', Icons.bar_chart, () {
              Navigator.pushNamed(context, '/reports');
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardCard(String title, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4.0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50.0, color: Colors.blue),
            const SizedBox(height: 10.0),
            Text(
              title,
              style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

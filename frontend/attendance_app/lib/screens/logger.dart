import 'package:logging/logging.dart';
import 'package:flutter/material.dart';
import '../utils/themes.dart'; // Import themes

final Logger logger = Logger('AttendanceApp');
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

void setupLogger() {
  logger.level = Level.ALL;
  logger.onRecord.listen((record) {
    print('${record.level.name}: ${record.time}: ${record.message}');
  });
}

void toggleThemeMode() {
  themeNotifier.value = themeNotifier.value == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
}
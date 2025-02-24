import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:attendance_app/main.dart';

void main() {
  testWidgets('Check if Login button is present', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp());

    expect(find.text('Login'), findsOneWidget);
  });

  testWidgets('Check if fingerprint authentication is visible', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp());
    
    // Wait for UI to build completely
    await tester.pumpAndSettle();

    // Find a button or container with fingerprint authentication
    expect(find.byKey(Key('fingerprintButton')), findsOneWidget);
  });
}

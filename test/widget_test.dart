// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Amore App smoke test', (WidgetTester tester) async {
    // Build a simple test app to verify basic Flutter functionality
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Amore Test')),
        body: const Center(child: Text('Amore Beta 測試應用程式')),
      ),
    ));

    // Verify that the app starts correctly
    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.text('Amore Beta 測試應用程式'), findsOneWidget);
  });
}

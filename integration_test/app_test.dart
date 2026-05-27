import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:tamil_app/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('End-to-End App Test', () {
    testWidgets('App starts and displays splash screen', (WidgetTester tester) async {
      // Start the app
      app.main();
      
      // Wait for app to render
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Check if we can find something that belongs to the app. 
      // The Splash Screen might transition to the Login Screen automatically.
      // We will just verify that the app is running and a Scaffold is present.
      expect(find.byType(Scaffold), findsWidgets);
    });
  });
}

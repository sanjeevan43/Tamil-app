import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:tamil_app/screens/writing_practice_game.dart';
import 'package:tamil_app/providers/enhanced_progress_provider.dart';

class MockProgressProvider extends EnhancedProgressProvider {
  @override String get userName => 'Test User';
  @override String get avatar => '👤';
  @override int get totalStars => 0;
  @override int get totalCoins => 0;
  @override int get streakDays => 0;
  @override int get level => 1;
  @override String? get userId => 'test_id';
  @override List<Map<String, dynamic>> get dailyMissions => [{'title': 'Letter Pro', 'current': 0, 'target': 5, 'completed': false}];
  
  @override Future<void> addRewards({int coins = 0, int stars = 0, String? missionId}) async {}
  @override Future<void> initializeProgress({String? uid}) async {}
  @override Future<void> syncToCloud() async {}
}

void main() {
  testWidgets('WritingPracticeGame UI Test', (WidgetTester tester) async {
    // We need to provide the EnhancedProgressProvider
    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<EnhancedProgressProvider>(
          create: (_) => MockProgressProvider(),
          child: const WritingPracticeGame(),
        ),
      ),
    );

    // Verify Title
    expect(find.text('WRITING PRACTICE'), findsOneWidget);

    // Verify Header text
    expect(find.text('Trace Letter'), findsOneWidget);

    // Verify background letter exists (opacity 0.15) - checking for the text itself
    // The Tamil letter from TamilData.uyirEzhuthukkal[0] is 'அ'
    expect(find.text('அ'), findsWidgets);

    // Test: Click Next without drawing should show snackbar
    await tester.tap(find.text('Next Letter'));
    await tester.pump();
    expect(find.text('Please draw the letter first!'), findsOneWidget);
  });
}

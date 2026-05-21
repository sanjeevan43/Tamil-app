import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:tamil_app/screens/tamil_letters_screen.dart';
import 'package:tamil_app/providers/enhanced_progress_provider.dart';
import 'package:tamil_app/services/firestore_service.dart';

// Mock for FirestoreService that doesn't use Firebase
class MockFirestoreService implements FirestoreService {
  @override Future<void> saveProgress(String uid, Map<String, dynamic> data) async {}
  @override Future<Map<String, dynamic>?> getProgress(String uid) async => null;
  
  // Implement other methods as no-ops for testing
  @override noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

// Mock for the progress provider using the mocked firestore
class MockProgressProvider extends EnhancedProgressProvider {
  MockProgressProvider() : super(firestore: MockFirestoreService());
  
  @override Future<void> addRewards({int coins = 0, int stars = 0, String? missionId}) async {}
  @override Future<void> initializeProgress({String? uid}) async {}
}

void main() {
  testWidgets('TamilLettersScreen UI and Interaction Test', (WidgetTester tester) async {
    // 1. Build the widget
    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<EnhancedProgressProvider>(
          create: (_) => MockProgressProvider(),
          child: const TamilLettersScreen(),
        ),
      ),
    );

    // 2. Verify basic UI elements
    expect(find.text('TAMIL ALPHABET'), findsOneWidget);
    expect(find.text('VOWELS (12)'), findsOneWidget);
    expect(find.text('CONSONANTS (18)'), findsOneWidget);

    // 3. Verify Vowels are visible by default (e.g., 'அ')
    expect(find.text('அ'), findsOneWidget);
    expect(find.text('a'), findsOneWidget); // Transliteration

    // 4. Test Tab Switching (Switch to Consonants)
    await tester.tap(find.text('CONSONANTS (18)'));
    await tester.pumpAndSettle(); // Wait for animation

    // Now 'க்' should be visible
    expect(find.text('க்'), findsOneWidget);
    expect(find.text('ik'), findsOneWidget);

    // 5. Test Interaction (Tap a letter card)
    await tester.tap(find.text('க்'));
    await tester.pump(); // Trigger SnackBar

    // Verify SnackBar appears
    expect(find.text('Playing க்'), findsOneWidget);
    expect(find.byIcon(Icons.volume_up), findsOneWidget);
  });
}

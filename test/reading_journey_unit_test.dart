import 'package:flutter_test/flutter_test.dart';
import 'package:tamil_app/data/reading_journey_data.dart';

void main() {
  group('ReadingJourneyData Unit Tests', () {
    test('getStageForLevel should return the correct stage for a level ID', () {
      // Level 1 should be in Stage 1
      final stage = ReadingJourneyData.getStageForLevel(1);
      expect(stage['id'], equals(1));
      expect(stage['name'], equals('Tamil Letters'));

      // Level 5 should be in Stage 2
      final stage2 = ReadingJourneyData.getStageForLevel(5);
      expect(stage2['id'], equals(2));
      expect(stage2['name'], equals('Simple Words'));
    });

    test('getLevelsForStage should return all levels associated with a stage', () {
      // Stage 1 has levels 1, 2, 3, 4
      final levels = ReadingJourneyData.getLevelsForStage(1);
      expect(levels.length, equals(4));
      expect(levels[0]['id'], equals(1));
      expect(levels[3]['id'], equals(4));
    });

    test('getStageForLevel should return first stage as fallback for invalid level', () {
      // Testing the orElse behavior in the data class
      final stage = ReadingJourneyData.getStageForLevel(999);
      expect(stage['id'], equals(1));
    });
  });
}

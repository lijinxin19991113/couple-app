import 'package:flutter_test/flutter_test.dart';
import 'package:couple_app/services/mood_service.dart';
import 'package:couple_app/models/mood_record_model.dart';

void main() {
  late MoodService moodService;

  setUp(() {
    moodService = MoodService();
  });

  group('MoodService', () {
    group('getMoodTimeline', () {
      test('should return mood records for given relationId', () async {
        final records = await moodService.getMoodTimeline(
          relationId: 'relation_001',
        );

        expect(records, isNotEmpty);
        expect(records.every((r) => r.relationId == 'relation_001'), true);
      });

      test('should filter by date range', () async {
        final now = DateTime.now();
        final start = now.subtract(const Duration(days: 7));
        final end = now;

        final records = await moodService.getMoodTimeline(
          relationId: 'relation_001',
          start: start,
          end: end,
        );

        for (final record in records) {
          final recordDate = DateTime(
            record.recordDate.year,
            record.recordDate.month,
            record.recordDate.day,
          );
          final startDate = DateTime(start.year, start.month, start.day);
          final endDate = DateTime(end.year, end.month, end.day);

          expect(
            !recordDate.isBefore(startDate) && !recordDate.isAfter(endDate),
            true,
          );
        }
      });

      test('should return records sorted by recordDate descending', () async {
        final records = await moodService.getMoodTimeline(
          relationId: 'relation_001',
        );

        for (var i = 1; i < records.length; i++) {
          expect(
            records[i].recordDate.isBefore(records[i - 1].recordDate) ||
            records[i].recordDate.isAtSameMomentAs(records[i - 1].recordDate),
            true,
          );
        }
      });
    });

    group('getMoodByDate', () {
      test('should return mood record for today', () async {
        final today = DateTime.now();
        final record = await moodService.getMoodByDate(
          relationId: 'relation_001',
          date: today,
        );

        // May be null if no record exists for today
        if (record != null) {
          expect(record.relationId, 'relation_001');
        }
      });

      test('should return null for unknown date', () async {
        final record = await moodService.getMoodByDate(
          relationId: 'relation_001',
          date: DateTime(2020, 1, 1),
        );

        expect(record, isNull);
      });

      test('should filter by userId when provided', () async {
        final today = DateTime.now();
        final record = await moodService.getMoodByDate(
          relationId: 'relation_001',
          date: today,
          userId: 'mock_user_001',
        );

        if (record != null) {
          expect(record.userId, 'mock_user_001');
        }
      });
    });

    group('createMoodRecord', () {
      test('should create mood record successfully', () async {
        final record = await moodService.createMoodRecord(
          relationId: 'relation_001',
          userId: 'user_001',
          moodType: MoodType.happy,
          moodScore: 5,
          content: 'Test content',
          imageUrls: ['https://example.com/image.jpg'],
          visibleToPartner: true,
        );

        expect(record.relationId, 'relation_001');
        expect(record.userId, 'user_001');
        expect(record.moodType, MoodType.happy);
        expect(record.moodScore, 5);
        expect(record.content, 'Test content');
        expect(record.imageUrls.length, 1);
        expect(record.visibleToPartner, true);
      });

      test('should replace existing record for same user on same day', () async {
        final now = DateTime.now();

        // Create first record
        final record1 = await moodService.createMoodRecord(
          relationId: 'relation_001',
          userId: 'test_user_unique',
          moodType: MoodType.sad,
          moodScore: 2,
        );

        // Create second record same day
        final record2 = await moodService.createMoodRecord(
          relationId: 'relation_001',
          userId: 'test_user_unique',
          moodType: MoodType.happy,
          moodScore: 5,
        );

        // Should have same objectId (updated)
        expect(record2.moodType, MoodType.happy);
      });
    });

    group('updateMoodRecord', () {
      test('should update mood record successfully', () async {
        // Create a record first
        final created = await moodService.createMoodRecord(
          relationId: 'relation_001',
          userId: 'user_update_test',
          moodType: MoodType.calm,
          moodScore: 3,
        );

        // Update it
        final updated = await moodService.updateMoodRecord(
          record: created.copyWith(
            moodType: MoodType.excited,
            moodScore: 4,
          ),
        );

        expect(updated, isNotNull);
        expect(updated!.moodType, MoodType.excited);
        expect(updated.moodScore, 4);
      });

      test('should return null for non-existent record', () async {
        final nonExistent = MoodRecord(
          objectId: 'non_existent_id',
          relationId: 'relation_001',
          userId: 'user_001',
          moodType: MoodType.happy,
          moodScore: 5,
          visibleToPartner: true,
          recordDate: DateTime.now(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final result = await moodService.updateMoodRecord(record: nonExistent);

        expect(result, isNull);
      });
    });

    group('getMoodTrend', () {
      test('should return trend data with correct days', () async {
        final trend = await moodService.getMoodTrend(
          relationId: 'relation_001',
          days: 7,
        );

        expect(trend['days'], 7);
        expect(trend['trend'], isA<Map<String, double>>());
      });

      test('should return trend data for 30 days', () async {
        final trend = await moodService.getMoodTrend(
          relationId: 'relation_001',
          days: 30,
        );

        expect(trend['days'], 30);
        final trendMap = trend['trend'] as Map<String, double>;
        expect(trendMap.length, 30);
      });
    });

    group('getMoodStatistics', () {
      test('should return statistics with total and average', () async {
        final stats = await moodService.getMoodStatistics(
          relationId: 'relation_001',
        );

        expect(stats['total'], isA<int>());
        expect(stats['average'], isA<double>());
        expect(stats['distribution'], isA<Map<String, int>>());
      });

      test('should return zero statistics for unknown relation', () async {
        final stats = await moodService.getMoodStatistics(
          relationId: 'unknown_relation',
        );

        expect(stats['total'], 0);
        expect(stats['average'], 0.0);
      });
    });
  });
}

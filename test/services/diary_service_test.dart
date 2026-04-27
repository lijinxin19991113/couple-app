import 'package:flutter_test/flutter_test.dart';
import 'package:couple_app/services/diary_service.dart';
import 'package:couple_app/models/diary_entry_model.dart';

void main() {
  late DiaryService diaryService;

  setUp(() {
    diaryService = DiaryService();
  });

  group('DiaryService', () {
    group('getDiaryTimeline', () {
      test('should return diary entries for given relationId', () async {
        final entries = await diaryService.getDiaryTimeline(
          relationId: 'relation_001',
        );

        expect(entries, isNotEmpty);
        expect(entries.every((e) => e.relationId == 'relation_001'), true);
      });

      test('should return entries sorted by recordDate descending', () async {
        final entries = await diaryService.getDiaryTimeline(
          relationId: 'relation_001',
        );

        for (var i = 1; i < entries.length; i++) {
          expect(
            entries[i].recordDate.isBefore(entries[i - 1].recordDate) ||
            entries[i].recordDate.isAtSameMomentAs(entries[i - 1].recordDate),
            true,
          );
        }
      });

      test('should paginate results correctly', () async {
        final page1 = await diaryService.getDiaryTimeline(
          relationId: 'relation_001',
          page: 1,
          pageSize: 2,
        );

        final page2 = await diaryService.getDiaryTimeline(
          relationId: 'relation_001',
          page: 2,
          pageSize: 2,
        );

        // Page 2 should have different entries than page 1
        if (page1.isNotEmpty && page2.isNotEmpty) {
          final page1Ids = page1.map((e) => e.objectId).toSet();
          final page2Ids = page2.map((e) => e.objectId).toSet();
          expect(page1Ids.intersection(page2Ids), isEmpty);
        }
      });

      test('should return empty list for page beyond data', () async {
        final entries = await diaryService.getDiaryTimeline(
          relationId: 'relation_001',
          page: 100,
          pageSize: 20,
        );

        expect(entries, isEmpty);
      });
    });

    group('getDiaryById', () {
      test('should return diary entry for existing id', () async {
        // First get an existing id
        final timeline = await diaryService.getDiaryTimeline(
          relationId: 'relation_001',
        );
        final existingId = timeline.first.objectId;

        final entry = await diaryService.getDiaryById(existingId);

        expect(entry, isNotNull);
        expect(entry!.objectId, existingId);
      });

      test('should return null for non-existent id', () async {
        final entry = await diaryService.getDiaryById('non_existent_id');

        expect(entry, isNull);
      });
    });

    group('createDiaryEntry', () {
      test('should create diary entry successfully', () async {
        final entry = await diaryService.createDiaryEntry(
          relationId: 'relation_001',
          authorId: 'user_001',
          title: 'New Diary Entry',
          content: 'This is the content of my new diary entry.',
          moodType: DiaryMoodType.happy,
          weather: WeatherType.sunny,
          locationText: 'Shanghai',
          isPrivate: false,
        );

        expect(entry.title, 'New Diary Entry');
        expect(entry.content, 'This is the content of my new diary entry.');
        expect(entry.moodType, DiaryMoodType.happy);
        expect(entry.weather, WeatherType.sunny);
        expect(entry.locationText, 'Shanghai');
        expect(entry.isPrivate, false);
        expect(entry.relationId, 'relation_001');
        expect(entry.authorId, 'user_001');
      });

      test('should create entry with images', () async {
        final entry = await diaryService.createDiaryEntry(
          relationId: 'relation_001',
          authorId: 'user_001',
          title: 'Diary with images',
          content: 'Content with images',
          imageUrls: [
            'https://example.com/image1.jpg',
            'https://example.com/image2.jpg',
          ],
        );

        expect(entry.imageUrls.length, 2);
      });

      test('should use default values for optional fields', () async {
        final entry = await diaryService.createDiaryEntry(
          relationId: 'relation_001',
          authorId: 'user_001',
          title: 'Minimal Entry',
          content: 'Minimal content',
        );

        expect(entry.moodType, DiaryMoodType.calm);
        expect(entry.weather, WeatherType.sunny);
        expect(entry.imageUrls, isEmpty);
        expect(entry.isPrivate, false);
        expect(entry.recordDate.year, DateTime.now().year);
      });
    });

    group('updateDiaryEntry', () {
      test('should update diary entry successfully', () async {
        // Create first
        final created = await diaryService.createDiaryEntry(
          relationId: 'relation_001',
          authorId: 'user_001',
          title: 'Original Title',
          content: 'Original content',
        );

        // Update
        final updated = await diaryService.updateDiaryEntry(
          id: created.objectId,
          title: 'Updated Title',
          moodType: DiaryMoodType.excited,
        );

        expect(updated, isNotNull);
        expect(updated!.title, 'Updated Title');
        expect(updated.moodType, DiaryMoodType.excited);
        // Unchanged fields should remain
        expect(updated.content, 'Original content');
      });

      test('should return null for non-existent id', () async {
        final updated = await diaryService.updateDiaryEntry(
          id: 'non_existent_id',
          title: 'New Title',
        );

        expect(updated, isNull);
      });

      test('should update multiple fields at once', () async {
        final created = await diaryService.createDiaryEntry(
          relationId: 'relation_001',
          authorId: 'user_001',
          title: 'Original',
          content: 'Original content',
          moodType: DiaryMoodType.calm,
          weather: WeatherType.cloudy,
        );

        final updated = await diaryService.updateDiaryEntry(
          id: created.objectId,
          title: 'New Title',
          content: 'New content',
          moodType: DiaryMoodType.happy,
          weather: WeatherType.sunny,
          isPrivate: true,
        );

        expect(updated!.title, 'New Title');
        expect(updated.content, 'New content');
        expect(updated.moodType, DiaryMoodType.happy);
        expect(updated.weather, WeatherType.sunny);
        expect(updated.isPrivate, true);
      });
    });

    group('deleteDiaryEntry', () {
      test('should delete diary entry successfully', () async {
        // Create first
        final created = await diaryService.createDiaryEntry(
          relationId: 'relation_001',
          authorId: 'user_001',
          title: 'To be deleted',
          content: 'This will be deleted',
        );

        final result = await diaryService.deleteDiaryEntry(created.objectId);

        expect(result, true);

        // Verify deleted
        final entry = await diaryService.getDiaryById(created.objectId);
        expect(entry, isNull);
      });

      test('should return false for non-existent id', () async {
        final result = await diaryService.deleteDiaryEntry('non_existent_id');

        expect(result, false);
      });
    });

    group('getDiaryByDate', () {
      test('should return entries for specific date', () async {
        final today = DateTime.now();
        final entries = await diaryService.getDiaryByDate(
          relationId: 'relation_001',
          date: today,
        );

        for (final entry in entries) {
          expect(entry.recordDate.year, today.year);
          expect(entry.recordDate.month, today.month);
          expect(entry.recordDate.day, today.day);
        }
      });

      test('should return empty list for date with no entries', () async {
        final entries = await diaryService.getDiaryByDate(
          relationId: 'relation_001',
          date: DateTime(2020, 1, 1),
        );

        expect(entries, isEmpty);
      });
    });

    group('getDiaryDates', () {
      test('should return set of dates with diary entries', () async {
        final dates = await diaryService.getDiaryDates(
          relationId: 'relation_001',
          year: DateTime.now().year,
          month: DateTime.now().month,
        );

        expect(dates, isA<Set<DateTime>>());
      });

      test('should return empty set for month with no entries', () async {
        final dates = await diaryService.getDiaryDates(
          relationId: 'relation_001',
          year: 2020,
          month: 1,
        );

        expect(dates, isEmpty);
      });
    });
  });
}

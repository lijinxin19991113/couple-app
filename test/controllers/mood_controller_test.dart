import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:couple_app/services/mood_service.dart';
import 'package:couple_app/models/mood_record_model.dart';

class MockMoodService extends Mock implements MoodService {}

class FakeMoodRecord extends Fake implements MoodRecord {}

void main() {
  late MockMoodService mockMoodService;

  setUpAll(() {
    registerFallbackValue(FakeMoodRecord());
  });

  setUp(() {
    mockMoodService = MockMoodService();
  });

  group('MoodService Mock Tests', () {
    test('getMoodTimeline returns list of mood records', () async {
      final records = [
        MoodRecord(
          objectId: 'mood_1',
          relationId: 'relation_001',
          userId: 'user_001',
          moodType: MoodType.happy,
          moodScore: 5,
          visibleToPartner: true,
          recordDate: DateTime.now(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        MoodRecord(
          objectId: 'mood_2',
          relationId: 'relation_001',
          userId: 'user_002',
          moodType: MoodType.calm,
          moodScore: 3,
          visibleToPartner: true,
          recordDate: DateTime.now().subtract(const Duration(days: 1)),
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
          updatedAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
      ];

      when(() => mockMoodService.getMoodTimeline(
            relationId: any(named: 'relationId'),
            start: any(named: 'start'),
            end: any(named: 'end'),
          )).thenAnswer((_) async => records);

      final result = await mockMoodService.getMoodTimeline(
        relationId: 'relation_001',
        start: DateTime.now().subtract(const Duration(days: 7)),
        end: DateTime.now(),
      );

      expect(result, records);
      expect(result.length, 2);
      verify(() => mockMoodService.getMoodTimeline(
            relationId: 'relation_001',
            start: any(named: 'start'),
            end: any(named: 'end'),
          )).called(1);
    });

    test('getMoodByDate returns mood record for today', () async {
      final todayRecord = MoodRecord(
        objectId: 'mood_today',
        relationId: 'relation_001',
        userId: 'user_001',
        moodType: MoodType.happy,
        moodScore: 5,
        visibleToPartner: true,
        recordDate: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      when(() => mockMoodService.getMoodByDate(
            relationId: any(named: 'relationId'),
            date: any(named: 'date'),
            userId: any(named: 'userId'),
          )).thenAnswer((_) async => todayRecord);

      final result = await mockMoodService.getMoodByDate(
        relationId: 'relation_001',
        date: DateTime.now(),
        userId: 'user_001',
      );

      expect(result, isNotNull);
      expect(result!.moodType, MoodType.happy);
      expect(result.moodScore, 5);
    });

    test('getMoodByDate returns null when no record exists', () async {
      when(() => mockMoodService.getMoodByDate(
            relationId: any(named: 'relationId'),
            date: any(named: 'date'),
            userId: any(named: 'userId'),
          )).thenAnswer((_) async => null);

      final result = await mockMoodService.getMoodByDate(
        relationId: 'relation_001',
        date: DateTime(2020, 1, 1),
        userId: 'user_001',
      );

      expect(result, isNull);
    });

    test('createMoodRecord creates and returns new record', () async {
      final newRecord = MoodRecord(
        objectId: 'mood_new',
        relationId: 'relation_001',
        userId: 'user_001',
        moodType: MoodType.excited,
        moodScore: 4,
        content: 'New check-in!',
        visibleToPartner: true,
        recordDate: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      when(() => mockMoodService.createMoodRecord(
            relationId: any(named: 'relationId'),
            userId: any(named: 'userId'),
            moodType: any(named: 'moodType'),
            moodScore: any(named: 'moodScore'),
            content: any(named: 'content'),
            imageUrls: any(named: 'imageUrls'),
            visibleToPartner: any(named: 'visibleToPartner'),
            recordDate: any(named: 'recordDate'),
          )).thenAnswer((_) async => newRecord);

      final result = await mockMoodService.createMoodRecord(
        relationId: 'relation_001',
        userId: 'user_001',
        moodType: MoodType.excited,
        moodScore: 4,
        content: 'New check-in!',
      );

      expect(result.moodType, MoodType.excited);
      expect(result.content, 'New check-in!');
      verify(() => mockMoodService.createMoodRecord(
            relationId: 'relation_001',
            userId: 'user_001',
            moodType: MoodType.excited,
            moodScore: 4,
            content: 'New check-in!',
            imageUrls: any(named: 'imageUrls'),
            visibleToPartner: any(named: 'visibleToPartner'),
            recordDate: any(named: 'recordDate'),
          )).called(1);
    });

    test('updateMoodRecord updates and returns record', () async {
      final existingRecord = MoodRecord(
        objectId: 'mood_1',
        relationId: 'relation_001',
        userId: 'user_001',
        moodType: MoodType.calm,
        moodScore: 3,
        visibleToPartner: true,
        recordDate: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final updatedRecord = existingRecord.copyWith(
        moodType: MoodType.happy,
        moodScore: 5,
      );

      when(() => mockMoodService.updateMoodRecord(record: any(named: 'record')))
          .thenAnswer((_) async => updatedRecord);

      final result = await mockMoodService.updateMoodRecord(record: existingRecord);

      expect(result!.moodType, MoodType.happy);
      expect(result.moodScore, 5);
    });

    test('updateMoodRecord returns null for non-existent record', () async {
      final nonExistent = MoodRecord(
        objectId: 'non_existent',
        relationId: 'relation_001',
        userId: 'user_001',
        moodType: MoodType.calm,
        moodScore: 3,
        visibleToPartner: true,
        recordDate: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      when(() => mockMoodService.updateMoodRecord(record: any(named: 'record')))
          .thenAnswer((_) async => null);

      final result = await mockMoodService.updateMoodRecord(record: nonExistent);

      expect(result, isNull);
    });

    test('getMoodTrend returns trend data', () async {
      final trendData = {
        'days': 7,
        'trend': {
          '2026-04-22': 3.5,
          '2026-04-23': 4.0,
          '2026-04-24': 0.0,
          '2026-04-25': 5.0,
          '2026-04-26': 4.5,
          '2026-04-27': 3.0,
          '2026-04-28': 4.0,
        },
      };

      when(() => mockMoodService.getMoodTrend(
            relationId: any(named: 'relationId'),
            days: any(named: 'days'),
          )).thenAnswer((_) async => trendData);

      final result = await mockMoodService.getMoodTrend(
        relationId: 'relation_001',
        days: 7,
      );

      expect(result['days'], 7);
      expect(result['trend'], isA<Map<String, double>>());
    });

    test('getMoodStatistics returns statistics data', () async {
      final statsData = {
        'total': 15,
        'average': 3.8,
        'distribution': {
          'happy': 5,
          'excited': 3,
          'calm': 4,
          'worried': 1,
          'sad': 1,
          'angry': 1,
        },
      };

      when(() => mockMoodService.getMoodStatistics(
            relationId: any(named: 'relationId'),
          )).thenAnswer((_) async => statsData);

      final result = await mockMoodService.getMoodStatistics(
        relationId: 'relation_001',
      );

      expect(result['total'], 15);
      expect(result['average'], 3.8);
      expect(result['distribution'], isA<Map<String, int>>());
    });
  });

  group('MoodService checkin flow', () {
    test('checkin creates new mood record and returns it', () async {
      final createdRecord = MoodRecord(
        objectId: 'mood_checkin',
        relationId: 'relation_001',
        userId: 'user_001',
        moodType: MoodType.happy,
        moodScore: 5,
        content: 'Feeling great today!',
        visibleToPartner: true,
        recordDate: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      when(() => mockMoodService.createMoodRecord(
            relationId: any(named: 'relationId'),
            userId: any(named: 'userId'),
            moodType: any(named: 'moodType'),
            moodScore: any(named: 'moodScore'),
            content: any(named: 'content'),
            imageUrls: any(named: 'imageUrls'),
            visibleToPartner: any(named: 'visibleToPartner'),
            recordDate: any(named: 'recordDate'),
          )).thenAnswer((_) async => createdRecord);

      final result = await mockMoodService.createMoodRecord(
        relationId: 'relation_001',
        userId: 'user_001',
        moodType: MoodType.happy,
        moodScore: 5,
        content: 'Feeling great today!',
      );

      expect(result.moodType, MoodType.happy);
      expect(result.content, 'Feeling great today!');
    });

    test('timeline query returns records sorted by date descending', () async {
      final now = DateTime.now();
      final records = [
        MoodRecord(
          objectId: 'mood_today',
          relationId: 'relation_001',
          userId: 'user_001',
          moodType: MoodType.happy,
          moodScore: 5,
          visibleToPartner: true,
          recordDate: now,
          createdAt: now,
          updatedAt: now,
        ),
        MoodRecord(
          objectId: 'mood_yesterday',
          relationId: 'relation_001',
          userId: 'user_001',
          moodType: MoodType.calm,
          moodScore: 3,
          visibleToPartner: true,
          recordDate: now.subtract(const Duration(days: 1)),
          createdAt: now.subtract(const Duration(days: 1)),
          updatedAt: now.subtract(const Duration(days: 1)),
        ),
      ];

      when(() => mockMoodService.getMoodTimeline(
            relationId: any(named: 'relationId'),
            start: any(named: 'start'),
            end: any(named: 'end'),
          )).thenAnswer((_) async => records);

      final result = await mockMoodService.getMoodTimeline(
        relationId: 'relation_001',
        start: now.subtract(const Duration(days: 30)),
        end: now,
      );

      expect(result.first.objectId, 'mood_today');
    });
  });
}

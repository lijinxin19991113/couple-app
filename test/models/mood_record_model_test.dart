import 'package:flutter_test/flutter_test.dart';
import 'package:couple_app/models/mood_record_model.dart';

void main() {
  group('MoodRecord', () {
    final testJson = {
      'objectId': 'mood_123',
      'relationId': 'relation_001',
      'userId': 'user_001',
      'moodType': 'happy',
      'moodScore': 5,
      'content': '今天很开心！',
      'imageUrls': [
        'https://example.com/image1.jpg',
        'https://example.com/image2.jpg',
      ],
      'visibleToPartner': true,
      'recordDate': '2026-04-28T00:00:00.000Z',
      'createdAt': '2026-04-28T10:00:00.000Z',
      'updatedAt': '2026-04-28T10:00:00.000Z',
    };

    test('fromJson should correctly parse valid JSON', () {
      final record = MoodRecord.fromJson(testJson);

      expect(record.objectId, 'mood_123');
      expect(record.relationId, 'relation_001');
      expect(record.userId, 'user_001');
      expect(record.moodType, MoodType.happy);
      expect(record.moodScore, 5);
      expect(record.content, '今天很开心！');
      expect(record.imageUrls.length, 2);
      expect(record.visibleToPartner, true);
    });

    test('fromJson should handle missing fields with defaults', () {
      final minimalJson = {
        'relationId': 'relation_001',
        'userId': 'user_001',
      };

      final record = MoodRecord.fromJson(minimalJson);

      expect(record.objectId, '');
      expect(record.moodType, MoodType.calm);
      expect(record.moodScore, 3);
      expect(record.content, null);
      expect(record.imageUrls, isEmpty);
      expect(record.visibleToPartner, true);
    });

    test('fromJson should parse imageUrls correctly', () {
      final record = MoodRecord.fromJson(testJson);

      expect(record.imageUrls, hasLength(2));
      expect(record.imageUrls[0], 'https://example.com/image1.jpg');
    });

    test('toJson should correctly serialize record', () {
      final record = MoodRecord(
        objectId: 'mood_123',
        relationId: 'relation_001',
        userId: 'user_001',
        moodType: MoodType.happy,
        moodScore: 5,
        content: '今天很开心！',
        imageUrls: ['https://example.com/image1.jpg'],
        visibleToPartner: true,
        recordDate: DateTime.parse('2026-04-28T00:00:00.000Z'),
        createdAt: DateTime.parse('2026-04-28T10:00:00.000Z'),
        updatedAt: DateTime.parse('2026-04-28T10:00:00.000Z'),
      );

      final json = record.toJson();

      expect(json['objectId'], 'mood_123');
      expect(json['moodType'], 'happy');
      expect(json['moodScore'], 5);
      expect(json['imageUrls'], ['https://example.com/image1.jpg']);
    });

    test('copyWith should create a new instance with updated fields', () {
      final original = MoodRecord(
        objectId: 'mood_123',
        relationId: 'relation_001',
        userId: 'user_001',
        moodType: MoodType.happy,
        moodScore: 5,
        visibleToPartner: true,
        recordDate: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final updated = original.copyWith(
        moodType: MoodType.excited,
        moodScore: 4,
      );

      expect(updated.moodType, MoodType.excited);
      expect(updated.moodScore, 4);
      expect(original.moodType, MoodType.happy);
      expect(original.moodScore, 5);
    });
  });

  group('MoodType', () {
    test('fromString should return correct enum values', () {
      expect(MoodType.fromString('happy'), MoodType.happy);
      expect(MoodType.fromString('excited'), MoodType.excited);
      expect(MoodType.fromString('calm'), MoodType.calm);
      expect(MoodType.fromString('worried'), MoodType.worried);
      expect(MoodType.fromString('sad'), MoodType.sad);
      expect(MoodType.fromString('angry'), MoodType.angry);
      expect(MoodType.fromString('unknown'), MoodType.calm);
      expect(MoodType.fromString(null), MoodType.calm);
    });
  });

  group('MoodTypeX extension', () {
    test('label should return Chinese labels', () {
      expect(MoodType.happy.label, '开心');
      expect(MoodType.excited.label, '兴奋');
      expect(MoodType.calm.label, '平静');
      expect(MoodType.worried.label, '担心');
      expect(MoodType.sad.label, '难过');
      expect(MoodType.angry.label, '生气');
    });

    test('emoji should return correct emojis', () {
      expect(MoodType.happy.emoji, '😊');
      expect(MoodType.excited.emoji, '🤩');
      expect(MoodType.calm.emoji, '😌');
      expect(MoodType.worried.emoji, '😟');
      expect(MoodType.sad.emoji, '😢');
      expect(MoodType.angry.emoji, '😠');
    });
  });

  group('MoodRecordX extension', () {
    test('moodEmoji should return mood type emoji', () {
      final record = MoodRecord(
        objectId: 'mood_1',
        relationId: 'relation_001',
        userId: 'user_001',
        moodType: MoodType.happy,
        moodScore: 5,
        visibleToPartner: true,
        recordDate: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(record.moodEmoji, '😊');
    });

    test('contentPreview should return null for empty content', () {
      final record = MoodRecord(
        objectId: 'mood_1',
        relationId: 'relation_001',
        userId: 'user_001',
        moodType: MoodType.happy,
        moodScore: 5,
        content: null,
        visibleToPartner: true,
        recordDate: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(record.contentPreview, null);
    });

    test('contentPreview should return null for whitespace-only content', () {
      final record = MoodRecord(
        objectId: 'mood_1',
        relationId: 'relation_001',
        userId: 'user_001',
        moodType: MoodType.happy,
        moodScore: 5,
        content: '   ',
        visibleToPartner: true,
        recordDate: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(record.contentPreview, null);
    });

    test('contentPreview should return full text if <= 40 characters', () {
      final record = MoodRecord(
        objectId: 'mood_1',
        relationId: 'relation_001',
        userId: 'user_001',
        moodType: MoodType.happy,
        moodScore: 5,
        content: '今天心情不错',
        visibleToPartner: true,
        recordDate: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(record.contentPreview, '今天心情不错');
    });

    test('contentPreview should truncate text > 40 characters', () {
      final longContent = '这是一段非常非常长的内容，超过了四十个字符的限制，需要进行截断处理。';
      final record = MoodRecord(
        objectId: 'mood_1',
        relationId: 'relation_001',
        userId: 'user_001',
        moodType: MoodType.happy,
        moodScore: 5,
        content: longContent,
        visibleToPartner: true,
        recordDate: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final preview = record.contentPreview;
      expect(preview, isNotNull);
      expect(preview!.length, lessThanOrEqualTo(43)); // 40 + '...'
      expect(preview.endsWith('...'), true);
    });
  });
}

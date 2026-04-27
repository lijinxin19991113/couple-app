import 'package:flutter_test/flutter_test.dart';
import 'package:couple_app/models/diary_entry_model.dart';

void main() {
  group('DiaryEntry', () {
    final testJson = {
      'objectId': 'diary_123',
      'relationId': 'relation_001',
      'authorId': 'user_001',
      'title': '美好的一天',
      'content': '今天我们一起去了公园，天气非常棒！',
      'imageUrls': [
        'https://example.com/photo1.jpg',
        'https://example.com/photo2.jpg',
      ],
      'moodType': 'happy',
      'weather': 'sunny',
      'locationText': '上海世纪公园',
      'isPrivate': false,
      'createdAt': '2026-04-28T10:00:00.000Z',
      'updatedAt': '2026-04-28T10:00:00.000Z',
      'recordDate': '2026-04-28T00:00:00.000Z',
    };

    test('fromJson should correctly parse valid JSON', () {
      final entry = DiaryEntry.fromJson(testJson);

      expect(entry.objectId, 'diary_123');
      expect(entry.relationId, 'relation_001');
      expect(entry.authorId, 'user_001');
      expect(entry.title, '美好的一天');
      expect(entry.content, '今天我们一起去了公园，天气非常棒！');
      expect(entry.imageUrls.length, 2);
      expect(entry.moodType, DiaryMoodType.happy);
      expect(entry.weather, WeatherType.sunny);
      expect(entry.locationText, '上海世纪公园');
      expect(entry.isPrivate, false);
    });

    test('fromJson should handle missing fields with defaults', () {
      final minimalJson = {
        'relationId': 'relation_001',
        'authorId': 'user_001',
        'title': 'Test',
        'content': 'Test content',
      };

      final entry = DiaryEntry.fromJson(minimalJson);

      expect(entry.objectId, '');
      expect(entry.moodType, DiaryMoodType.calm);
      expect(entry.weather, WeatherType.sunny);
      expect(entry.imageUrls, isEmpty);
      expect(entry.isPrivate, false);
    });

    test('fromJson should parse imageUrls correctly', () {
      final entry = DiaryEntry.fromJson(testJson);

      expect(entry.imageUrls, hasLength(2));
      expect(entry.imageUrls[0], 'https://example.com/photo1.jpg');
    });

    test('toJson should correctly serialize entry', () {
      final entry = DiaryEntry(
        objectId: 'diary_123',
        relationId: 'relation_001',
        authorId: 'user_001',
        title: '美好的一天',
        content: '今天我们一起去了公园，天气非常棒！',
        imageUrls: ['https://example.com/photo1.jpg'],
        moodType: DiaryMoodType.happy,
        weather: WeatherType.sunny,
        locationText: '上海',
        isPrivate: false,
        createdAt: DateTime.parse('2026-04-28T10:00:00.000Z'),
        updatedAt: DateTime.parse('2026-04-28T10:00:00.000Z'),
        recordDate: DateTime.parse('2026-04-28T00:00:00.000Z'),
      );

      final json = entry.toJson();

      expect(json['objectId'], 'diary_123');
      expect(json['title'], '美好的一天');
      expect(json['moodType'], 'happy');
      expect(json['weather'], 'sunny');
      expect(json['imageUrls'], ['https://example.com/photo1.jpg']);
    });

    test('copyWith should create a new instance with updated fields', () {
      final original = DiaryEntry(
        objectId: 'diary_123',
        relationId: 'relation_001',
        authorId: 'user_001',
        title: 'Original Title',
        content: 'Original content',
        moodType: DiaryMoodType.happy,
        weather: WeatherType.sunny,
        isPrivate: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        recordDate: DateTime.now(),
      );

      final updated = original.copyWith(
        title: 'Updated Title',
        moodType: DiaryMoodType.excited,
      );

      expect(updated.title, 'Updated Title');
      expect(updated.moodType, DiaryMoodType.excited);
      expect(original.title, 'Original Title');
    });
  });

  group('WeatherType', () {
    test('fromString should return correct enum values', () {
      expect(WeatherType.fromString('sunny'), WeatherType.sunny);
      expect(WeatherType.fromString('cloudy'), WeatherType.cloudy);
      expect(WeatherType.fromString('rainy'), WeatherType.rainy);
      expect(WeatherType.fromString('snowy'), WeatherType.snowy);
      expect(WeatherType.fromString('windy'), WeatherType.windy);
      expect(WeatherType.fromString('foggy'), WeatherType.foggy);
      expect(WeatherType.fromString('unknown'), WeatherType.sunny);
      expect(WeatherType.fromString(null), WeatherType.sunny);
    });
  });

  group('DiaryMoodType', () {
    test('fromString should return correct enum values', () {
      expect(DiaryMoodType.fromString('happy'), DiaryMoodType.happy);
      expect(DiaryMoodType.fromString('excited'), DiaryMoodType.excited);
      expect(DiaryMoodType.fromString('calm'), DiaryMoodType.calm);
      expect(DiaryMoodType.fromString('worried'), DiaryMoodType.worried);
      expect(DiaryMoodType.fromString('sad'), DiaryMoodType.sad);
      expect(DiaryMoodType.fromString('angry'), DiaryMoodType.angry);
      expect(DiaryMoodType.fromString('unknown'), DiaryMoodType.calm);
    });
  });

  group('WeatherTypeX extension', () {
    test('label should return Chinese labels', () {
      expect(WeatherType.sunny.label, '晴天');
      expect(WeatherType.cloudy.label, '多云');
      expect(WeatherType.rainy.label, '雨天');
      expect(WeatherType.snowy.label, '雪天');
      expect(WeatherType.windy.label, '大风');
      expect(WeatherType.foggy.label, '雾天');
    });

    test('icon should return correct emojis', () {
      expect(WeatherType.sunny.icon, '☀️');
      expect(WeatherType.cloudy.icon, '☁️');
      expect(WeatherType.rainy.icon, '🌧️');
      expect(WeatherType.snowy.icon, '❄️');
      expect(WeatherType.windy.icon, '💨');
      expect(WeatherType.foggy.icon, '🌫️');
    });
  });

  group('DiaryMoodTypeX extension', () {
    test('label should return Chinese labels', () {
      expect(DiaryMoodType.happy.label, '开心');
      expect(DiaryMoodType.excited.label, '兴奋');
      expect(DiaryMoodType.calm.label, '平静');
      expect(DiaryMoodType.worried.label, '担心');
      expect(DiaryMoodType.sad.label, '难过');
      expect(DiaryMoodType.angry.label, '生气');
    });

    test('emoji should return correct emojis', () {
      expect(DiaryMoodType.happy.emoji, '😊');
      expect(DiaryMoodType.excited.emoji, '🤩');
      expect(DiaryMoodType.calm.emoji, '😌');
      expect(DiaryMoodType.worried.emoji, '😟');
      expect(DiaryMoodType.sad.emoji, '😢');
      expect(DiaryMoodType.angry.emoji, '😠');
    });
  });

  group('DiaryEntryX extension', () {
    test('moodEmoji should return mood type emoji', () {
      final entry = DiaryEntry(
        objectId: 'diary_1',
        relationId: 'relation_001',
        authorId: 'user_001',
        title: 'Test',
        content: 'Test content',
        moodType: DiaryMoodType.happy,
        weather: WeatherType.sunny,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        recordDate: DateTime.now(),
      );

      expect(entry.moodEmoji, '😊');
    });

    test('weatherIcon should return weather icon', () {
      final entry = DiaryEntry(
        objectId: 'diary_1',
        relationId: 'relation_001',
        authorId: 'user_001',
        title: 'Test',
        content: 'Test content',
        moodType: DiaryMoodType.happy,
        weather: WeatherType.rainy,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        recordDate: DateTime.now(),
      );

      expect(entry.weatherIcon, '🌧️');
    });

    test('contentPreview should return null for empty content', () {
      final entry = DiaryEntry(
        objectId: 'diary_1',
        relationId: 'relation_001',
        authorId: 'user_001',
        title: 'Test',
        content: '',
        moodType: DiaryMoodType.happy,
        weather: WeatherType.sunny,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        recordDate: DateTime.now(),
      );

      expect(entry.contentPreview, null);
    });

    test('contentPreview should return full text if <= 60 characters', () {
      final entry = DiaryEntry(
        objectId: 'diary_1',
        relationId: 'relation_001',
        authorId: 'user_001',
        title: 'Test',
        content: '今天天气很好，我们一起出去玩了。',
        moodType: DiaryMoodType.happy,
        weather: WeatherType.sunny,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        recordDate: DateTime.now(),
      );

      expect(entry.contentPreview, '今天天气很好，我们一起出去玩了。');
    });

    test('contentPreview should truncate text > 60 characters', () {
      final longContent = '这是一段非常非常长的日记内容，超过了六十个字符的限制，需要进行截断处理以保证显示效果。';
      final entry = DiaryEntry(
        objectId: 'diary_1',
        relationId: 'relation_001',
        authorId: 'user_001',
        title: 'Test',
        content: longContent,
        moodType: DiaryMoodType.happy,
        weather: WeatherType.sunny,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        recordDate: DateTime.now(),
      );

      final preview = entry.contentPreview;
      expect(preview, isNotNull);
      expect(preview!.length, lessThanOrEqualTo(63)); // 60 + '...'
      expect(preview.endsWith('...'), true);
    });

    test('dateKey should return formatted date string', () {
      final entry = DiaryEntry(
        objectId: 'diary_1',
        relationId: 'relation_001',
        authorId: 'user_001',
        title: 'Test',
        content: 'Test content',
        moodType: DiaryMoodType.happy,
        weather: WeatherType.sunny,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        recordDate: DateTime(2026, 4, 5),
      );

      expect(entry.dateKey, '2026-04-05');
    });

    test('dateKey should pad single digit month and day', () {
      final entry = DiaryEntry(
        objectId: 'diary_1',
        relationId: 'relation_001',
        authorId: 'user_001',
        title: 'Test',
        content: 'Test content',
        moodType: DiaryMoodType.happy,
        weather: WeatherType.sunny,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        recordDate: DateTime(2026, 1, 9),
      );

      expect(entry.dateKey, '2026-01-09');
    });
  });
}

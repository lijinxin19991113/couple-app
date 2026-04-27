import 'package:flutter_test/flutter_test.dart';
import 'package:couple_app/models/anniversary_model.dart';

void main() {
  group('Anniversary', () {
    final testJson = {
      'objectId': 'anniv_123',
      'relationId': 'relation_001',
      'title': '恋爱纪念日',
      'date': '2026-06-01T00:00:00.000Z',
      'type': 'love',
      'repeatType': 'yearly',
      'reminderEnabled': true,
      'reminderTime': '2026-06-01T09:00:00.000Z',
      'note': '重要的日子',
      'createdBy': 'user_001',
      'createdAt': '2026-04-28T10:00:00.000Z',
      'updatedAt': '2026-04-28T10:00:00.000Z',
    };

    test('fromJson should correctly parse valid JSON', () {
      final anniversary = Anniversary.fromJson(testJson);

      expect(anniversary.objectId, 'anniv_123');
      expect(anniversary.relationId, 'relation_001');
      expect(anniversary.title, '恋爱纪念日');
      expect(anniversary.type, AnniversaryType.love);
      expect(anniversary.repeatType, AnniversaryRepeatType.yearly);
      expect(anniversary.reminderEnabled, true);
      expect(anniversary.note, '重要的日子');
    });

    test('fromJson should handle missing fields with defaults', () {
      final minimalJson = {
        'relationId': 'relation_001',
        'title': 'Test',
        'date': '2026-04-28T00:00:00.000Z',
        'createdBy': 'user_001',
      };

      final anniversary = Anniversary.fromJson(minimalJson);

      expect(anniversary.objectId, '');
      expect(anniversary.type, AnniversaryType.custom);
      expect(anniversary.repeatType, AnniversaryRepeatType.none);
      expect(anniversary.reminderEnabled, false);
    });

    test('fromJson should handle firstMet type variations', () {
      final jsonWithFirstMet = {
        ...testJson,
        'type': 'first_met',
      };
      final anniversary1 = Anniversary.fromJson(jsonWithFirstMet);
      expect(anniversary1.type, AnniversaryType.firstMet);

      final jsonWithFirstMet2 = {
        ...testJson,
        'type': 'firstMet',
      };
      final anniversary2 = Anniversary.fromJson(jsonWithFirstMet2);
      expect(anniversary2.type, AnniversaryType.firstMet);
    });

    test('toJson should correctly serialize anniversary', () {
      final anniversary = Anniversary(
        objectId: 'anniv_123',
        relationId: 'relation_001',
        title: '恋爱纪念日',
        date: DateTime.parse('2026-06-01T00:00:00.000Z'),
        type: AnniversaryType.love,
        repeatType: AnniversaryRepeatType.yearly,
        reminderEnabled: true,
        createdBy: 'user_001',
        createdAt: DateTime.parse('2026-04-28T10:00:00.000Z'),
        updatedAt: DateTime.parse('2026-04-28T10:00:00.000Z'),
      );

      final json = anniversary.toJson();

      expect(json['objectId'], 'anniv_123');
      expect(json['title'], '恋爱纪念日');
      expect(json['type'], 'love'); // uses rawValue
      expect(json['repeatType'], 'yearly');
    });

    test('copyWith should create a new instance with updated fields', () {
      final original = Anniversary(
        objectId: 'anniv_123',
        relationId: 'relation_001',
        title: 'Original Title',
        date: DateTime.now(),
        type: AnniversaryType.love,
        repeatType: AnniversaryRepeatType.yearly,
        reminderEnabled: false,
        createdBy: 'user_001',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final updated = original.copyWith(
        title: 'Updated Title',
        reminderEnabled: true,
      );

      expect(updated.title, 'Updated Title');
      expect(updated.reminderEnabled, true);
      expect(original.title, 'Original Title');
    });
  });

  group('AnniversaryType', () {
    test('fromString should return correct enum values', () {
      expect(AnniversaryType.fromString('love'), AnniversaryType.love);
      expect(AnniversaryType.fromString('birthday'), AnniversaryType.birthday);
      expect(AnniversaryType.fromString('first_met'), AnniversaryType.firstMet);
      expect(AnniversaryType.fromString('firstMet'), AnniversaryType.firstMet);
      expect(AnniversaryType.fromString('custom'), AnniversaryType.custom);
      expect(AnniversaryType.fromString('unknown'), AnniversaryType.custom);
    });

    test('rawValue should return correct string values', () {
      expect(AnniversaryType.love.rawValue, 'love');
      expect(AnniversaryType.birthday.rawValue, 'birthday');
      expect(AnniversaryType.firstMet.rawValue, 'first_met');
      expect(AnniversaryType.custom.rawValue, 'custom');
    });
  });

  group('AnniversaryRepeatType', () {
    test('fromString should return correct enum values', () {
      expect(AnniversaryRepeatType.fromString('none'), AnniversaryRepeatType.none);
      expect(AnniversaryRepeatType.fromString('yearly'), AnniversaryRepeatType.yearly);
      expect(AnniversaryRepeatType.fromString('monthly'), AnniversaryRepeatType.monthly);
      expect(AnniversaryRepeatType.fromString('weekly'), AnniversaryRepeatType.weekly);
      expect(AnniversaryRepeatType.fromString('unknown'), AnniversaryRepeatType.none);
    });
  });

  group('AnniversaryTypeX extension', () {
    test('displayName should return Chinese labels', () {
      expect(AnniversaryType.love.displayName, '恋爱');
      expect(AnniversaryType.birthday.displayName, '生日');
      expect(AnniversaryType.firstMet.displayName, '初见');
      expect(AnniversaryType.custom.displayName, '自定义');
    });

    test('icon should return correct emojis', () {
      expect(AnniversaryType.love.icon, '💖');
      expect(AnniversaryType.birthday.icon, '🎂');
      expect(AnniversaryType.firstMet.icon, '🌟');
      expect(AnniversaryType.custom.icon, '📅');
    });
  });

  group('AnniversaryRepeatTypeX extension', () {
    test('displayName should return Chinese labels', () {
      expect(AnniversaryRepeatType.none.displayName, '不重复');
      expect(AnniversaryRepeatType.yearly.displayName, '每年');
      expect(AnniversaryRepeatType.monthly.displayName, '每月');
      expect(AnniversaryRepeatType.weekly.displayName, '每周');
    });
  });

  group('AnniversaryX extension', () {
    test('id should return objectId', () {
      final anniversary = Anniversary(
        objectId: 'anniv_123',
        relationId: 'relation_001',
        title: 'Test',
        date: DateTime.now(),
        type: AnniversaryType.love,
        repeatType: AnniversaryRepeatType.none,
        reminderEnabled: false,
        createdBy: 'user_001',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(anniversary.id, 'anniv_123');
    });

    test('countdownDays should calculate days for non-repeating anniversary', () {
      // Anniversary is 10 days in the future
      final futureDate = DateTime.now().add(const Duration(days: 10));
      final anniversary = Anniversary(
        objectId: 'anniv_123',
        relationId: 'relation_001',
        title: 'Test',
        date: futureDate,
        type: AnniversaryType.love,
        repeatType: AnniversaryRepeatType.none,
        reminderEnabled: false,
        createdBy: 'user_001',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(anniversary.countdownDays, 10);
    });

    test('countdownDays should calculate days for past non-repeating anniversary', () {
      // Anniversary was 5 days ago
      final pastDate = DateTime.now().subtract(const Duration(days: 5));
      final anniversary = Anniversary(
        objectId: 'anniv_123',
        relationId: 'relation_001',
        title: 'Test',
        date: pastDate,
        type: AnniversaryType.love,
        repeatType: AnniversaryRepeatType.none,
        reminderEnabled: false,
        createdBy: 'user_001',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(anniversary.countdownDays, -5);
    });

    test('countdownDays should calculate days for yearly repeating anniversary', () {
      // Anniversary date is tomorrow (same month/day next year if passed)
      final now = DateTime.now();
      final anniversaryDate = DateTime(now.year, now.month, now.day + 1);
      final anniversary = Anniversary(
        objectId: 'anniv_123',
        relationId: 'relation_001',
        title: 'Test',
        date: anniversaryDate,
        type: AnniversaryType.love,
        repeatType: AnniversaryRepeatType.yearly,
        reminderEnabled: false,
        createdBy: 'user_001',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(anniversary.countdownDays, 1);
    });

    test('countdownDays should handle yearly anniversary that already passed this year', () {
      final now = DateTime.now();
      // Anniversary was 30 days ago
      final anniversaryDate = DateTime(now.year, now.month - (now.day < 15 ? 1 : 0), (now.day - 30 + 31) % 31 + 1);
      final anniversary = Anniversary(
        objectId: 'anniv_123',
        relationId: 'relation_001',
        title: 'Test',
        date: anniversaryDate,
        type: AnniversaryType.love,
        repeatType: AnniversaryRepeatType.yearly,
        reminderEnabled: false,
        createdBy: 'user_001',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Should return positive value (days until next yearly occurrence)
      expect(anniversary.countdownDays, greaterThan(0));
    });
  });
}

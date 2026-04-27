import '../models/anniversary_model.dart';

/// 纪念日服务（当前为 Mock）
class AnniversaryService {
  final List<Anniversary> _store = <Anniversary>[
    Anniversary(
      objectId: 'ann_1',
      relationId: 'relation_001',
      title: '恋爱纪念日',
      date: DateTime(2021, 5, 20),
      type: AnniversaryType.love,
      repeatType: AnniversaryRepeatType.yearly,
      reminderEnabled: true,
      reminderTime: DateTime(2026, 4, 27, 9, 0),
      note: '每年都要去吃那家烤肉',
      createdBy: 'mock_user_001',
      createdAt: DateTime(2021, 5, 20, 12, 0),
      updatedAt: DateTime(2026, 4, 1, 12, 0),
    ),
    Anniversary(
      objectId: 'ann_2',
      relationId: 'relation_001',
      title: 'Ta 的生日',
      date: DateTime(1998, 8, 11),
      type: AnniversaryType.birthday,
      repeatType: AnniversaryRepeatType.yearly,
      reminderEnabled: true,
      reminderTime: DateTime(2026, 4, 27, 10, 0),
      note: null,
      createdBy: 'user_partner',
      createdAt: DateTime(2022, 1, 6, 18, 0),
      updatedAt: DateTime(2025, 12, 24, 20, 30),
    ),
  ];

  Future<List<Anniversary>> getAnniversaryList({required String relationId}) async {
    await Future.delayed(const Duration(milliseconds: 220));
    final list = _store.where((item) => item.relationId == relationId).toList()
      ..sort((a, b) => calculateCountdown(a).compareTo(calculateCountdown(b)));
    return list;
  }

  Future<Anniversary> createAnniversary({required Anniversary anniversary}) async {
    await Future.delayed(const Duration(milliseconds: 340));
    final now = DateTime.now();
    final created = anniversary.copyWith(
      objectId: 'ann_${now.millisecondsSinceEpoch}',
      createdAt: now,
      updatedAt: now,
    );
    _store.add(created);
    return created;
  }

  Future<Anniversary?> updateAnniversary({required Anniversary anniversary}) async {
    await Future.delayed(const Duration(milliseconds: 280));
    final index = _store.indexWhere((item) => item.objectId == anniversary.objectId);
    if (index < 0) {
      return null;
    }
    final updated = anniversary.copyWith(updatedAt: DateTime.now());
    _store[index] = updated;
    return updated;
  }

  Future<bool> deleteAnniversary({required String objectId}) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _store.removeWhere((item) => item.objectId == objectId) > 0;
  }

  Future<List<Anniversary>> getUpcomingAnniversaries({
    required String relationId,
    int withinDays = 30,
  }) async {
    final list = await getAnniversaryList(relationId: relationId);
    return list.where((item) {
      final days = calculateCountdown(item);
      return days >= 0 && days <= withinDays;
    }).toList();
  }

  int calculateCountdown(Anniversary anniversary, {DateTime? fromDate}) {
    final base = fromDate ?? DateTime.now();
    final now = DateTime(base.year, base.month, base.day);
    final source = DateTime(
      anniversary.date.year,
      anniversary.date.month,
      anniversary.date.day,
    );

    DateTime next = source;

    switch (anniversary.repeatType) {
      case AnniversaryRepeatType.none:
        next = source;
        break;
      case AnniversaryRepeatType.yearly:
        next = DateTime(now.year, source.month, source.day);
        if (next.isBefore(now)) {
          next = DateTime(now.year + 1, source.month, source.day);
        }
        break;
      case AnniversaryRepeatType.monthly:
        next = DateTime(now.year, now.month, source.day);
        if (next.isBefore(now)) {
          next = DateTime(now.year, now.month + 1, source.day);
        }
        break;
      case AnniversaryRepeatType.weekly:
        final weekday = source.weekday;
        next = now;
        while (next.weekday != weekday || next.isBefore(now)) {
          next = next.add(const Duration(days: 1));
        }
        break;
    }

    if (anniversary.repeatType == AnniversaryRepeatType.none && next.isBefore(now)) {
      return -now.difference(next).inDays;
    }

    return next.difference(now).inDays;
  }
}

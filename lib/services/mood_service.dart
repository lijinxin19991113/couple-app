import '../models/mood_record_model.dart';

/// 心情服务（当前为 Mock）
class MoodService {
  final List<MoodRecord> _store = <MoodRecord>[
    MoodRecord(
      objectId: 'mood_1',
      relationId: 'relation_001',
      userId: 'mock_user_001',
      moodType: MoodType.happy,
      moodScore: 5,
      content: '一起吃了超好吃的晚餐，幸福感拉满。',
      imageUrls: <String>[
        'https://images.unsplash.com/photo-1522673607200-164d1b6ce486?auto=format&fit=crop&w=700&q=80'
      ],
      visibleToPartner: true,
      recordDate: DateTime(2026, 4, 28),
      createdAt: DateTime(2026, 4, 28, 9, 18),
      updatedAt: DateTime(2026, 4, 28, 9, 18),
    ),
    MoodRecord(
      objectId: 'mood_2',
      relationId: 'relation_001',
      userId: 'user_partner',
      moodType: MoodType.calm,
      moodScore: 3,
      content: '今天工作比较平稳，晚上想早点回家。',
      imageUrls: const <String>[],
      visibleToPartner: true,
      recordDate: DateTime(2026, 4, 27),
      createdAt: DateTime(2026, 4, 27, 20, 8),
      updatedAt: DateTime(2026, 4, 27, 20, 8),
    ),
  ];

  Future<List<MoodRecord>> getMoodTimeline({
    required String relationId,
    DateTime? start,
    DateTime? end,
  }) async {
    await Future.delayed(const Duration(milliseconds: 260));
    final startDate = start ?? DateTime.now().subtract(const Duration(days: 30));
    final endDate = end ?? DateTime.now().add(const Duration(days: 1));

    final list = _store.where((item) {
      final day = DateTime(item.recordDate.year, item.recordDate.month, item.recordDate.day);
      return item.relationId == relationId &&
          !day.isBefore(DateTime(startDate.year, startDate.month, startDate.day)) &&
          !day.isAfter(DateTime(endDate.year, endDate.month, endDate.day));
    }).toList()
      ..sort((a, b) => b.recordDate.compareTo(a.recordDate));

    return list;
  }

  Future<MoodRecord?> getMoodByDate({
    required String relationId,
    required DateTime date,
    String? userId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 180));

    final target = DateTime(date.year, date.month, date.day);
    for (final item in _store) {
      final day = DateTime(item.recordDate.year, item.recordDate.month, item.recordDate.day);
      if (item.relationId == relationId && day == target) {
        if (userId == null || userId == item.userId) {
          return item;
        }
      }
    }
    return null;
  }

  Future<MoodRecord> createMoodRecord({
    required String relationId,
    required String userId,
    required MoodType moodType,
    required int moodScore,
    String? content,
    List<String> imageUrls = const <String>[],
    bool visibleToPartner = true,
    DateTime? recordDate,
  }) async {
    await Future.delayed(const Duration(milliseconds: 420));

    final now = DateTime.now();
    final created = MoodRecord(
      objectId: 'mood_${now.millisecondsSinceEpoch}',
      relationId: relationId,
      userId: userId,
      moodType: moodType,
      moodScore: moodScore,
      content: content,
      imageUrls: imageUrls,
      visibleToPartner: visibleToPartner,
      recordDate: recordDate ?? now,
      createdAt: now,
      updatedAt: now,
    );

    _store.removeWhere((item) {
      final d1 = DateTime(item.recordDate.year, item.recordDate.month, item.recordDate.day);
      final d2 = DateTime(created.recordDate.year, created.recordDate.month, created.recordDate.day);
      return item.relationId == relationId && item.userId == userId && d1 == d2;
    });

    _store.insert(0, created);
    return created;
  }

  Future<MoodRecord?> updateMoodRecord({required MoodRecord record}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _store.indexWhere((item) => item.objectId == record.objectId);
    if (index < 0) {
      return null;
    }
    final updated = record.copyWith(updatedAt: DateTime.now());
    _store[index] = updated;
    return updated;
  }

  Future<Map<String, dynamic>> getMoodTrend({
    required String relationId,
    int days = 7,
  }) async {
    await Future.delayed(const Duration(milliseconds: 220));

    final now = DateTime.now();
    final trend = <String, double>{};

    for (var i = days - 1; i >= 0; i--) {
      final day = now.subtract(Duration(days: i));
      final key = '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
      final records = _store.where((item) {
        final target = DateTime(item.recordDate.year, item.recordDate.month, item.recordDate.day);
        return item.relationId == relationId &&
            target == DateTime(day.year, day.month, day.day);
      }).toList();

      final avg = records.isEmpty
          ? 0.0
          : records.map((item) => item.moodScore).reduce((a, b) => a + b) / records.length;
      trend[key] = avg;
    }

    return <String, dynamic>{
      'days': days,
      'trend': trend,
    };
  }

  Future<Map<String, dynamic>> getMoodStatistics({required String relationId}) async {
    await Future.delayed(const Duration(milliseconds: 220));

    final records = _store.where((item) => item.relationId == relationId).toList();
    if (records.isEmpty) {
      return <String, dynamic>{
        'total': 0,
        'average': 0.0,
        'distribution': <String, int>{},
      };
    }

    final total = records.length;
    final average =
        records.map((item) => item.moodScore).reduce((a, b) => a + b) / total;
    final distribution = <String, int>{};

    for (final type in MoodType.values) {
      distribution[type.name] =
          records.where((item) => item.moodType == type).length;
    }

    return <String, dynamic>{
      'total': total,
      'average': average,
      'distribution': distribution,
    };
  }
}

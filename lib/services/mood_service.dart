import 'package:get/get.dart';

import '../models/mood_record_model.dart';

/// 心情服务
class MoodService extends GetxService {
  /// 获取心情时间线
  Future<List<MoodRecord>> getMoodTimeline({
    required String relationId,
    required DateTime startDate,
    required DateTime endDate,
    int page = 1,
    int pageSize = 20,
  }) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 500));

    // 模拟数据
    return _generateMockRecords(relationId, startDate, endDate);
  }

  /// 按日期获取心情记录
  Future<MoodRecord?> getMoodByDate({
    required String relationId,
    required DateTime date,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final records = _generateMockRecords(
      relationId,
      date,
      date.add(const Duration(days: 1)),
    );

    return records.isNotEmpty ? records.first : null;
  }

  /// 创建心情记录
  Future<MoodRecord> createMoodRecord({
    required String relationId,
    required String userId,
    required MoodType moodType,
    required int moodScore,
    String? content,
    List<String> imageUrls = const [],
    bool visibleToPartner = true,
    DateTime? recordDate,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final now = DateTime.now();
    return MoodRecord(
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
  }

  /// 更新心情记录
  Future<MoodRecord> updateMoodRecord({
    required String id,
    MoodType? moodType,
    int? moodScore,
    String? content,
    List<String>? imageUrls,
    bool? visibleToPartner,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));

    // 模拟更新返回
    return MoodRecord(
      objectId: id,
      relationId: 'relation_001',
      userId: 'user_001',
      moodType: moodType ?? MoodType.calm,
      moodScore: moodScore ?? 3,
      content: content,
      imageUrls: imageUrls ?? [],
      visibleToPartner: visibleToPartner ?? true,
      recordDate: DateTime.now(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// 获取心情趋势
  Future<Map<String, dynamic>> getMoodTrend({
    required String relationId,
    int days = 7,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));

    final now = DateTime.now();
    final trend = <String, dynamic>{};

    for (var i = days - 1; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dateKey =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      trend[dateKey] = {
        'avgScore': (3 + (i % 3)).toDouble(),
        'count': 1 + (i % 2),
      };
    }

    return {
      'trend': trend,
      'days': days,
    };
  }

  /// 获取心情统计
  Future<Map<String, dynamic>> getMoodStatistics({
    required String relationId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));

    return {
      'totalRecords': 42,
      'avgScore': 3.5,
      'mostCommonMood': MoodType.happy.value,
      'thisWeekRecords': 7,
      'thisWeekAvgScore': 3.8,
      'moodDistribution': {
        MoodType.happy.value: 15,
        MoodType.excited.value: 8,
        MoodType.calm.value: 10,
        MoodType.worried.value: 5,
        MoodType.sad.value: 3,
        MoodType.angry.value: 1,
      },
    };
  }

  /// 生成模拟数据
  List<MoodRecord> _generateMockRecords(
    String relationId,
    DateTime startDate,
    DateTime endDate,
  ) {
    final records = <MoodRecord>[];
    final moods = MoodType.values;
    final contents = [
      '今天和他一起做了早餐，很幸福～',
      '工作有点累，但是想到晚上能见面就开心了',
      '一起看了电影，他选的片子很不错',
      '天气很好，牵手散步中',
      '有点小争执，但是很快就和好了',
      '收到了他送的小礼物，开心！',
      '一起做饭，厨房变成了战场哈哈',
      '今天有点低落，他在身边安慰我',
    ];

    var currentDate = startDate;
    var index = 0;

    while (currentDate.isBefore(endDate) && records.length < 10) {
      // 每天2条记录（双方各一条）
      for (var userIdx = 0; userIdx < 2; userIdx++) {
        if (records.length >= 10) break;

        final mood = moods[(index + userIdx) % moods.length];
        final score = (index + userIdx) % 5 + 1;

        records.add(MoodRecord(
          objectId: 'mood_mock_$index\_$userIdx',
          relationId: relationId,
          userId: userIdx == 0 ? 'user_001' : 'user_002',
          moodType: mood,
          moodScore: score,
          content: contents[(index + userIdx) % contents.length],
          imageUrls: [],
          visibleToPartner: true,
          recordDate: currentDate,
          createdAt: currentDate,
          updatedAt: currentDate,
        ));
      }

      currentDate = currentDate.add(const Duration(days: 1));
      index++;
    }

    return records;
  }
}

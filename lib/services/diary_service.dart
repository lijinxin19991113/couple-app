import '../models/diary_entry_model.dart';

/// 日记服务（当前为 Mock）
class DiaryService {
  final List<DiaryEntry> _store = <DiaryEntry>[
    DiaryEntry(
      objectId: 'diary_1',
      relationId: 'relation_001',
      authorId: 'mock_user_001',
      title: '我们的第一篇日记',
      content: '今天是特别的一天，我们决定开始记录属于我们的故事。每一天都是新的开始，希望我们能一直这样幸福下去。',
      imageUrls: <String>[
        'https://images.unsplash.com/photo-1522673607200-164d1b6ce486?auto=format&fit=crop&w=700&q=80',
        'https://images.unsplash.com/photo-1516589178581-6cd7833ae3b2?auto=format&fit=crop&w=700&q=80',
      ],
      moodType: DiaryMoodType.happy,
      weather: WeatherType.sunny,
      locationText: '上海',
      isPrivate: false,
      createdAt: DateTime(2026, 4, 28, 10, 30),
      updatedAt: DateTime(2026, 4, 28, 10, 30),
      recordDate: DateTime(2026, 4, 28),
    ),
    DiaryEntry(
      objectId: 'diary_2',
      relationId: 'relation_001',
      authorId: 'user_partner',
      title: '周末约会',
      content: '今天一起去看了电影，吃了火锅，非常开心！希望能一直这样幸福下去。',
      imageUrls: <String>[
        'https://images.unsplash.com/photo-1532634922-8fe0b757fb13?auto=format&fit=crop&w=700&q=80',
      ],
      moodType: DiaryMoodType.excited,
      weather: WeatherType.cloudy,
      locationText: '北京',
      isPrivate: false,
      createdAt: DateTime(2026, 4, 27, 20, 15),
      updatedAt: DateTime(2026, 4, 27, 20, 15),
      recordDate: DateTime(2026, 4, 27),
    ),
    DiaryEntry(
      objectId: 'diary_3',
      relationId: 'relation_001',
      authorId: 'mock_user_001',
      title: '下雨天',
      content: '窗外下着雨，听着雨声写日记，也是一种享受。希望明天天气会好起来。',
      imageUrls: <String>[],
      moodType: DiaryMoodType.calm,
      weather: WeatherType.rainy,
      locationText: '杭州',
      isPrivate: true,
      createdAt: DateTime(2026, 4, 26, 22, 0),
      updatedAt: DateTime(2026, 4, 26, 22, 0),
      recordDate: DateTime(2026, 4, 26),
    ),
    DiaryEntry(
      objectId: 'diary_4',
      relationId: 'relation_001',
      authorId: 'user_partner',
      title: '纪念日快乐',
      content: '今天是我们在一起的第100天，谢谢你一直陪在我身边。未来还有很长的路要走，我会好好珍惜我们的每一天。',
      imageUrls: <String>[
        'https://images.unsplash.com/photo-1518199266791-5375a83190b7?auto=format&fit=crop&w=700&q=80',
        'https://images.unsplash.com/photo-1529333166437-7750a6dd5a70?auto=format&fit=crop&w=700&q=80',
        'https://images.unsplash.com/photo-1516589178581-6cd7833ae3b2?auto=format&fit=crop&w=700&q=80',
      ],
      moodType: DiaryMoodType.happy,
      weather: WeatherType.sunny,
      locationText: '广州',
      isPrivate: false,
      createdAt: DateTime(2026, 4, 25, 18, 30),
      updatedAt: DateTime(2026, 4, 25, 18, 30),
      recordDate: DateTime(2026, 4, 25),
    ),
  ];

  /// 获取日记时间线
  Future<List<DiaryEntry>> getDiaryTimeline({
    required String relationId,
    int page = 1,
    int pageSize = 20,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final list = _store
        .where((item) => item.relationId == relationId)
        .toList()
      ..sort((a, b) => b.recordDate.compareTo(a.recordDate));

    final start = (page - 1) * pageSize;
    if (start >= list.length) return [];

    final end = (start + pageSize).clamp(0, list.length);
    return list.sublist(start, end);
  }

  /// 根据ID获取日记
  Future<DiaryEntry?> getDiaryById(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));

    try {
      return _store.firstWhere((item) => item.objectId == id);
    } catch (e) {
      return null;
    }
  }

  /// 创建日记
  Future<DiaryEntry> createDiaryEntry({
    required String relationId,
    required String authorId,
    required String title,
    required String content,
    List<String> imageUrls = const <String>[],
    DiaryMoodType moodType = DiaryMoodType.calm,
    WeatherType weather = WeatherType.sunny,
    String? locationText,
    bool isPrivate = false,
    DateTime? recordDate,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));

    final now = DateTime.now();
    final created = DiaryEntry(
      objectId: 'diary_${now.millisecondsSinceEpoch}',
      relationId: relationId,
      authorId: authorId,
      title: title,
      content: content,
      imageUrls: imageUrls,
      moodType: moodType,
      weather: weather,
      locationText: locationText,
      isPrivate: isPrivate,
      createdAt: now,
      updatedAt: now,
      recordDate: recordDate ?? DateTime(now.year, now.month, now.day),
    );

    _store.insert(0, created);
    return created;
  }

  /// 更新日记
  Future<DiaryEntry?> updateDiaryEntry({
    required String id,
    String? title,
    String? content,
    List<String>? imageUrls,
    DiaryMoodType? moodType,
    WeatherType? weather,
    String? locationText,
    bool? isPrivate,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final index = _store.indexWhere((item) => item.objectId == id);
    if (index < 0) return null;

    final current = _store[index];
    final updated = current.copyWith(
      title: title,
      content: content,
      imageUrls: imageUrls,
      moodType: moodType,
      weather: weather,
      locationText: locationText,
      isPrivate: isPrivate,
      updatedAt: DateTime.now(),
    );

    _store[index] = updated;
    return updated;
  }

  /// 删除日记
  Future<bool> deleteDiaryEntry(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));

    final lengthBefore = _store.length;
    _store.removeWhere((item) => item.objectId == id);
    return _store.length < lengthBefore;
  }

  /// 根据日期获取日记
  Future<List<DiaryEntry>> getDiaryByDate({
    required String relationId,
    required DateTime date,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));

    final target = DateTime(date.year, date.month, date.day);
    return _store.where((item) {
      final day = DateTime(item.recordDate.year, item.recordDate.month, item.recordDate.day);
      return item.relationId == relationId && day == target;
    }).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  /// 获取有日记的日期列表（用于日历标记）
  Future<Set<DateTime>> getDiaryDates({
    required String relationId,
    required int year,
    required int month,
  }) async {
    await Future.delayed(const Duration(milliseconds: 150));

    return _store
        .where((item) {
          return item.relationId == relationId &&
              item.recordDate.year == year &&
              item.recordDate.month == month;
        })
        .map((item) => DateTime(item.recordDate.year, item.recordDate.month, item.recordDate.day))
        .toSet();
  }
}

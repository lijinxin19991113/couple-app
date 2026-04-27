import 'package:equatable/equatable.dart';

/// 心情类型枚举
enum MoodType {
  happy('happy', '开心'),
  excited('excited', '兴奋'),
  calm('calm', '平静'),
  worried('worried', '担忧'),
  sad('sad', '难过'),
  angry('angry', '生气');

  final String value;
  final String label;

  const MoodType(this.value, this.label);

  static MoodType? fromString(String? value) {
    if (value == null) return null;
    return MoodType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => MoodType.calm,
    );
  }
}

/// 心情记录模型
class MoodRecord extends Equatable {
  /// 记录 ID
  final String objectId;

  /// 关系 ID
  final String relationId;

  /// 用户 ID
  final String userId;

  /// 心情类型
  final MoodType moodType;

  /// 心情分值 1-5
  final int moodScore;

  /// 心情文案
  final String? content;

  /// 图片 URL 列表（最多 3 张）
  final List<String> imageUrls;

  /// 是否对伴侣可见
  final bool visibleToPartner;

  /// 记录日期
  final DateTime recordDate;

  /// 创建时间
  final DateTime createdAt;

  /// 更新时间
  final DateTime updatedAt;

  const MoodRecord({
    required this.objectId,
    required this.relationId,
    required this.userId,
    required this.moodType,
    required this.moodScore,
    this.content,
    this.imageUrls = const [],
    this.visibleToPartner = true,
    required this.recordDate,
    required this.createdAt,
    required this.updatedAt,
  });

  /// 从 JSON 创建
  factory MoodRecord.fromJson(Map<String, dynamic> json) {
    return MoodRecord(
      objectId: json['objectId'] ?? json['id'] ?? '',
      relationId: json['relationId'] ?? '',
      userId: json['userId'] ?? '',
      moodType: MoodType.fromString(json['moodType']) ?? MoodType.calm,
      moodScore: (json['moodScore'] is int)
          ? json['moodScore']
          : int.tryParse(json['moodScore']?.toString() ?? '3') ?? 3,
      content: json['content'],
      imageUrls: (json['imageUrls'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      visibleToPartner: json['visibleToPartner'] ?? true,
      recordDate: _parseDateTime(json['recordDate']),
      createdAt: _parseDateTime(json['createdAt']),
      updatedAt: _parseDateTime(json['updatedAt']),
    );
  }

  /// 安全解析 DateTime
  static DateTime _parseDateTime(dynamic value) {
    if (value is DateTime) return value;
    if (value is String) {
      return DateTime.tryParse(value) ?? DateTime.now();
    }
    return DateTime.now();
  }

  /// 转为 JSON
  Map<String, dynamic> toJson() {
    return {
      'objectId': objectId,
      'relationId': relationId,
      'userId': userId,
      'moodType': moodType.value,
      'moodScore': moodScore,
      'content': content,
      'imageUrls': imageUrls,
      'visibleToPartner': visibleToPartner,
      'recordDate': recordDate.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// 复制并修改
  MoodRecord copyWith({
    String? objectId,
    String? relationId,
    String? userId,
    MoodType? moodType,
    int? moodScore,
    String? content,
    List<String>? imageUrls,
    bool? visibleToPartner,
    DateTime? recordDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MoodRecord(
      objectId: objectId ?? this.objectId,
      relationId: relationId ?? this.relationId,
      userId: userId ?? this.userId,
      moodType: moodType ?? this.moodType,
      moodScore: moodScore ?? this.moodScore,
      content: content ?? this.content,
      imageUrls: imageUrls ?? this.imageUrls,
      visibleToPartner: visibleToPartner ?? this.visibleToPartner,
      recordDate: recordDate ?? this.recordDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// 获取心情 emoji
  String get moodEmoji {
    switch (moodType) {
      case MoodType.happy:
        return '😊';
      case MoodType.excited:
        return '🤩';
      case MoodType.calm:
        return '😌';
      case MoodType.worried:
        return '😟';
      case MoodType.sad:
        return '😢';
      case MoodType.angry:
        return '😠';
    }
  }

  /// 获取心情文案预览（最多20字）
  String? get contentPreview {
    if (content == null || content!.isEmpty) return null;
    return content!.length > 20 ? '${content!.substring(0, 20)}...' : content;
  }

  @override
  List<Object?> get props => [
        objectId,
        relationId,
        userId,
        moodType,
        moodScore,
        content,
        imageUrls,
        visibleToPartner,
        recordDate,
        createdAt,
        updatedAt,
      ];
}

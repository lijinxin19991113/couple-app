import 'package:equatable/equatable.dart';

/// 纪念日类型
enum AnniversaryType {
  /// 恋爱纪念日
  love,

  /// 生日
  birthday,

  /// 初次见面
  firstMet,

  /// 自定义
  custom;

  String get displayName {
    switch (this) {
      case AnniversaryType.love:
        return '恋爱纪念日';
      case AnniversaryType.birthday:
        return '生日';
      case AnniversaryType.firstMet:
        return '初次见面';
      case AnniversaryType.custom:
        return '自定义';
    }
  }

  String get icon {
    switch (this) {
      case AnniversaryType.love:
        return '❤️';
      case AnniversaryType.birthday:
        return '🎂';
      case AnniversaryType.firstMet:
        return '💕';
      case AnniversaryType.custom:
        return '📅';
    }
  }

  static AnniversaryType fromString(String? value) {
    switch (value) {
      case 'love':
        return AnniversaryType.love;
      case 'birthday':
        return AnniversaryType.birthday;
      case 'firstMet':
        return AnniversaryType.firstMet;
      case 'custom':
        return AnniversaryType.custom;
      default:
        return AnniversaryType.custom;
    }
  }
}

/// 重复类型
enum RepeatType {
  /// 不重复
  none,

  /// 每年
  yearly,

  /// 每月
  monthly,

  /// 每周
  weekly;

  String get displayName {
    switch (this) {
      case RepeatType.none:
        return '不重复';
      case RepeatType.yearly:
        return '每年';
      case RepeatType.monthly:
        return '每月';
      case RepeatType.weekly:
        return '每周';
    }
  }

  static RepeatType fromString(String? value) {
    switch (value) {
      case 'none':
        return RepeatType.none;
      case 'yearly':
        return RepeatType.yearly;
      case 'monthly':
        return RepeatType.monthly;
      case 'weekly':
        return RepeatType.weekly;
      default:
        return RepeatType.none;
    }
  }
}

/// 纪念日模型
class AnniversaryModel extends Equatable {
  /// 纪念日 ID
  final String id;

  /// 关系 ID
  final String relationId;

  /// 标题
  final String title;

  /// 日期
  final DateTime date;

  /// 类型
  final AnniversaryType type;

  /// 重复类型
  final RepeatType repeatType;

  /// 是否启用提醒
  final bool reminderEnabled;

  /// 提醒时间
  final DateTime? reminderTime;

  /// 备注
  final String? note;

  /// 创建人
  final String? createdBy;

  /// 创建时间
  final DateTime createdAt;

  /// 更新时间
  final DateTime updatedAt;

  const AnniversaryModel({
    required this.id,
    required this.relationId,
    required this.title,
    required this.date,
    required this.type,
    required this.repeatType,
    required this.reminderEnabled,
    this.reminderTime,
    this.note,
    this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  /// 从 JSON 创建
  factory AnniversaryModel.fromJson(Map<String, dynamic> json) {
    return AnniversaryModel(
      id: json['id'] ?? json['objectId'] ?? '',
      relationId: json['relationId'] ?? '',
      title: json['title'] ?? '',
      date: _parseDateTime(json['date']),
      type: AnniversaryType.fromString(json['type']),
      repeatType: RepeatType.fromString(json['repeatType']),
      reminderEnabled: json['reminderEnabled'] == true,
      reminderTime: _parseNullableDateTime(json['reminderTime']),
      note: json['note'],
      createdBy: json['createdBy'],
      createdAt: _parseDateTime(json['createdAt']),
      updatedAt: _parseDateTime(json['updatedAt']),
    );
  }

  /// 解析 DateTime，支持字符串和毫秒时间戳
  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is String) {
      return DateTime.tryParse(value) ?? DateTime.now();
    }
    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    }
    return DateTime.now();
  }

  /// 解析可空 DateTime
  static DateTime? _parseNullableDateTime(dynamic value) {
    if (value == null) return null;
    if (value is String) {
      return DateTime.tryParse(value);
    }
    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    }
    return null;
  }

  /// 转为 JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'relationId': relationId,
      'title': title,
      'date': date.toIso8601String(),
      'type': type.name,
      'repeatType': repeatType.name,
      'reminderEnabled': reminderEnabled,
      'reminderTime': reminderTime?.toIso8601String(),
      'note': note,
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// 复制并修改
  AnniversaryModel copyWith({
    String? id,
    String? relationId,
    String? title,
    DateTime? date,
    AnniversaryType? type,
    RepeatType? repeatType,
    bool? reminderEnabled,
    DateTime? reminderTime,
    String? note,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AnniversaryModel(
      id: id ?? this.id,
      relationId: relationId ?? this.relationId,
      title: title ?? this.title,
      date: date ?? this.date,
      type: type ?? this.type,
      repeatType: repeatType ?? this.repeatType,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      reminderTime: reminderTime ?? this.reminderTime,
      note: note ?? this.note,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// 计算距离天数（考虑重复类型）
  int get countdownDays {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    var targetDate = DateTime(date.year, date.month, date.day);

    switch (repeatType) {
      case RepeatType.none:
        return targetDate.difference(today).inDays;

      case RepeatType.yearly:
        // 计算今年或明年的纪念日
        while (targetDate.isBefore(today) || targetDate.isAtSameMomentAs(today)) {
          targetDate = DateTime(targetDate.year + 1, targetDate.month, targetDate.day);
        }
        return targetDate.difference(today).inDays;

      case RepeatType.monthly:
        // 计算本月或下月的纪念日
        while (targetDate.isBefore(today) || targetDate.isAtSameMomentAs(today)) {
          final nextMonth = targetDate.month + 1;
          final year = targetDate.year + (nextMonth > 12 ? 1 : 0);
          final month = nextMonth > 12 ? 1 : nextMonth;
          final day = date.day;
          final maxDay = DateTime(year, month + 1, 0).day;
          targetDate = DateTime(year, month, day > maxDay ? maxDay : day);
        }
        return targetDate.difference(today).inDays;

      case RepeatType.weekly:
        // 计算本周或下周
        while (targetDate.isBefore(today) || targetDate.isAtSameMomentAs(today)) {
          targetDate = targetDate.add(const Duration(days: 7));
        }
        return targetDate.difference(today).inDays;
    }
  }

  @override
  List<Object?> get props => [
        id,
        relationId,
        title,
        date,
        type,
        repeatType,
        reminderEnabled,
        reminderTime,
        note,
        createdBy,
        createdAt,
        updatedAt,
      ];
}

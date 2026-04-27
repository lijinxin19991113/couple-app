import 'package:equatable/equatable.dart';

/// 纪念日类型
enum AnniversaryType {
  love,
  birthday,
  firstMet,
  custom;

  static AnniversaryType fromString(String? value) {
    switch (value) {
      case 'love':
        return AnniversaryType.love;
      case 'birthday':
        return AnniversaryType.birthday;
      case 'first_met':
      case 'firstMet':
        return AnniversaryType.firstMet;
      case 'custom':
        return AnniversaryType.custom;
      default:
        return AnniversaryType.custom;
    }
  }

  String get rawValue {
    switch (this) {
      case AnniversaryType.love:
        return 'love';
      case AnniversaryType.birthday:
        return 'birthday';
      case AnniversaryType.firstMet:
        return 'first_met';
      case AnniversaryType.custom:
        return 'custom';
    }
  }
}

/// 重复类型
enum AnniversaryRepeatType {
  none,
  yearly,
  monthly,
  weekly;

  static AnniversaryRepeatType fromString(String? value) {
    return AnniversaryRepeatType.values.firstWhere(
      (item) => item.name == value,
      orElse: () => AnniversaryRepeatType.none,
    );
  }
}

/// 纪念日模型
class Anniversary extends Equatable {
  final String objectId;
  final String relationId;
  final String title;
  final DateTime date;
  final AnniversaryType type;
  final AnniversaryRepeatType repeatType;
  final bool reminderEnabled;
  final DateTime? reminderTime;
  final String? note;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Anniversary({
    required this.objectId,
    required this.relationId,
    required this.title,
    required this.date,
    required this.type,
    required this.repeatType,
    required this.reminderEnabled,
    this.reminderTime,
    this.note,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Anniversary.fromJson(Map<String, dynamic> json) {
    return Anniversary(
      objectId: (json['objectId'] ?? json['id'] ?? '').toString(),
      relationId: (json['relationId'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      date: _parseDateTime(json['date']) ?? DateTime.now(),
      type: AnniversaryType.fromString(json['type']?.toString()),
      repeatType: AnniversaryRepeatType.fromString(json['repeatType']?.toString()),
      reminderEnabled: json['reminderEnabled'] == true,
      reminderTime: _parseDateTime(json['reminderTime']),
      note: json['note']?.toString(),
      createdBy: (json['createdBy'] ?? '').toString(),
      createdAt: _parseDateTime(json['createdAt']) ?? DateTime.now(),
      updatedAt: _parseDateTime(json['updatedAt']) ?? DateTime.now(),
    );
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value is DateTime) {
      return value;
    }
    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    }
    if (value is String) {
      return DateTime.tryParse(value);
    }
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'objectId': objectId,
      'relationId': relationId,
      'title': title,
      'date': date.toIso8601String(),
      'type': type.rawValue,
      'repeatType': repeatType.name,
      'reminderEnabled': reminderEnabled,
      'reminderTime': reminderTime?.toIso8601String(),
      'note': note,
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Anniversary copyWith({
    String? objectId,
    String? relationId,
    String? title,
    DateTime? date,
    AnniversaryType? type,
    AnniversaryRepeatType? repeatType,
    bool? reminderEnabled,
    DateTime? reminderTime,
    String? note,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Anniversary(
      objectId: objectId ?? this.objectId,
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

  @override
  List<Object?> get props => [
        objectId,
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

typedef AnniversaryModel = Anniversary;
typedef RepeatType = AnniversaryRepeatType;

extension AnniversaryTypeX on AnniversaryType {
  String get displayName {
    switch (this) {
      case AnniversaryType.love:
        return '恋爱';
      case AnniversaryType.birthday:
        return '生日';
      case AnniversaryType.firstMet:
        return '初见';
      case AnniversaryType.custom:
        return '自定义';
    }
  }

  String get icon {
    switch (this) {
      case AnniversaryType.love:
        return '💖';
      case AnniversaryType.birthday:
        return '🎂';
      case AnniversaryType.firstMet:
        return '🌟';
      case AnniversaryType.custom:
        return '📅';
    }
  }
}

extension AnniversaryRepeatTypeX on AnniversaryRepeatType {
  String get displayName {
    switch (this) {
      case AnniversaryRepeatType.none:
        return '不重复';
      case AnniversaryRepeatType.yearly:
        return '每年';
      case AnniversaryRepeatType.monthly:
        return '每月';
      case AnniversaryRepeatType.weekly:
        return '每周';
    }
  }
}

extension AnniversaryX on Anniversary {
  String get id => objectId;

  int get countdownDays {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final source = DateTime(date.year, date.month, date.day);
    switch (repeatType) {
      case AnniversaryRepeatType.none:
        return source.difference(today).inDays;
      case AnniversaryRepeatType.yearly:
        var next = DateTime(today.year, source.month, source.day);
        if (next.isBefore(today)) {
          next = DateTime(today.year + 1, source.month, source.day);
        }
        return next.difference(today).inDays;
      case AnniversaryRepeatType.monthly:
        var next = DateTime(today.year, today.month, source.day);
        if (next.isBefore(today)) {
          next = DateTime(today.year, today.month + 1, source.day);
        }
        return next.difference(today).inDays;
      case AnniversaryRepeatType.weekly:
        var next = today;
        while (next.weekday != source.weekday || next.isBefore(today)) {
          next = next.add(const Duration(days: 1));
        }
        return next.difference(today).inDays;
    }
  }
}

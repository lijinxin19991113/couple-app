import 'package:equatable/equatable.dart';

/// 天气类型
enum WeatherType {
  sunny,
  cloudy,
  rainy,
  snowy,
  windy,
  foggy;

  static WeatherType fromString(String? value) {
    return WeatherType.values.firstWhere(
      (item) => item.name == value,
      orElse: () => WeatherType.sunny,
    );
  }
}

/// 心情类型（与心情模块复用）
enum DiaryMoodType {
  happy,
  excited,
  calm,
  worried,
  sad,
  angry;

  static DiaryMoodType fromString(String? value) {
    return DiaryMoodType.values.firstWhere(
      (item) => item.name == value,
      orElse: () => DiaryMoodType.calm,
    );
  }
}

/// 日记条目
class DiaryEntry extends Equatable {
  final String objectId;
  final String relationId;
  final String authorId;
  final String title;
  final String content;
  final List<String> imageUrls;
  final DiaryMoodType moodType;
  final WeatherType weather;
  final String? locationText;
  final bool isPrivate;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime recordDate;

  const DiaryEntry({
    required this.objectId,
    required this.relationId,
    required this.authorId,
    required this.title,
    required this.content,
    this.imageUrls = const <String>[],
    this.moodType = DiaryMoodType.calm,
    this.weather = WeatherType.sunny,
    this.locationText,
    this.isPrivate = false,
    required this.createdAt,
    required this.updatedAt,
    required this.recordDate,
  });

  factory DiaryEntry.fromJson(Map<String, dynamic> json) {
    return DiaryEntry(
      objectId: (json['objectId'] ?? json['id'] ?? '').toString(),
      relationId: (json['relationId'] ?? '').toString(),
      authorId: (json['authorId'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      content: (json['content'] ?? '').toString(),
      imageUrls: (json['imageUrls'] as List<dynamic>? ?? const <dynamic>[])
          .map((item) => item.toString())
          .toList(),
      moodType: DiaryMoodType.fromString(json['moodType']?.toString()),
      weather: WeatherType.fromString(json['weather']?.toString()),
      locationText: json['locationText']?.toString(),
      isPrivate: json['isPrivate'] == true,
      createdAt: _parseDateTime(json['createdAt']) ?? DateTime.now(),
      updatedAt: _parseDateTime(json['updatedAt']) ?? DateTime.now(),
      recordDate: _parseDateTime(json['recordDate']) ?? DateTime.now(),
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
      'authorId': authorId,
      'title': title,
      'content': content,
      'imageUrls': imageUrls,
      'moodType': moodType.name,
      'weather': weather.name,
      'locationText': locationText,
      'isPrivate': isPrivate,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'recordDate': recordDate.toIso8601String(),
    };
  }

  DiaryEntry copyWith({
    String? objectId,
    String? relationId,
    String? authorId,
    String? title,
    String? content,
    List<String>? imageUrls,
    DiaryMoodType? moodType,
    WeatherType? weather,
    String? locationText,
    bool? isPrivate,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? recordDate,
  }) {
    return DiaryEntry(
      objectId: objectId ?? this.objectId,
      relationId: relationId ?? this.relationId,
      authorId: authorId ?? this.authorId,
      title: title ?? this.title,
      content: content ?? this.content,
      imageUrls: imageUrls ?? this.imageUrls,
      moodType: moodType ?? this.moodType,
      weather: weather ?? this.weather,
      locationText: locationText ?? this.locationText,
      isPrivate: isPrivate ?? this.isPrivate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      recordDate: recordDate ?? this.recordDate,
    );
  }

  @override
  List<Object?> get props => [
        objectId,
        relationId,
        authorId,
        title,
        content,
        imageUrls,
        moodType,
        weather,
        locationText,
        isPrivate,
        createdAt,
        updatedAt,
        recordDate,
      ];
}

extension DiaryMoodTypeX on DiaryMoodType {
  String get label {
    switch (this) {
      case DiaryMoodType.happy:
        return '开心';
      case DiaryMoodType.excited:
        return '兴奋';
      case DiaryMoodType.calm:
        return '平静';
      case DiaryMoodType.worried:
        return '担心';
      case DiaryMoodType.sad:
        return '难过';
      case DiaryMoodType.angry:
        return '生气';
    }
  }

  String get emoji {
    switch (this) {
      case DiaryMoodType.happy:
        return '😊';
      case DiaryMoodType.excited:
        return '🤩';
      case DiaryMoodType.calm:
        return '😌';
      case DiaryMoodType.worried:
        return '😟';
      case DiaryMoodType.sad:
        return '😢';
      case DiaryMoodType.angry:
        return '😠';
    }
  }
}

extension WeatherTypeX on WeatherType {
  String get label {
    switch (this) {
      case WeatherType.sunny:
        return '晴天';
      case WeatherType.cloudy:
        return '多云';
      case WeatherType.rainy:
        return '雨天';
      case WeatherType.snowy:
        return '雪天';
      case WeatherType.windy:
        return '大风';
      case WeatherType.foggy:
        return '雾天';
    }
  }

  String get icon {
    switch (this) {
      case WeatherType.sunny:
        return '☀️';
      case WeatherType.cloudy:
        return '☁️';
      case WeatherType.rainy:
        return '🌧️';
      case WeatherType.snowy:
        return '❄️';
      case WeatherType.windy:
        return '💨';
      case WeatherType.foggy:
        return '🌫️';
    }
  }
}

extension DiaryEntryX on DiaryEntry {
  String get moodEmoji => moodType.emoji;

  String get weatherIcon => weather.icon;

  String? get contentPreview {
    final text = content.trim();
    if (text.isEmpty) return null;
    if (text.length <= 60) return text;
    return '${text.substring(0, 60)}...';
  }

  String get dateKey {
    return '${recordDate.year}-${recordDate.month.toString().padLeft(2, '0')}-${recordDate.day.toString().padLeft(2, '0')}';
  }
}

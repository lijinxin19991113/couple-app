import 'package:equatable/equatable.dart';

/// 心情类型
enum MoodType {
  happy,
  excited,
  calm,
  worried,
  sad,
  angry;

  static MoodType fromString(String? value) {
    return MoodType.values.firstWhere(
      (item) => item.name == value,
      orElse: () => MoodType.calm,
    );
  }
}

/// 心情记录
class MoodRecord extends Equatable {
  final String objectId;
  final String relationId;
  final String userId;
  final MoodType moodType;
  final int moodScore;
  final String? content;
  final List<String> imageUrls;
  final bool visibleToPartner;
  final DateTime recordDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  const MoodRecord({
    required this.objectId,
    required this.relationId,
    required this.userId,
    required this.moodType,
    required this.moodScore,
    this.content,
    this.imageUrls = const <String>[],
    required this.visibleToPartner,
    required this.recordDate,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MoodRecord.fromJson(Map<String, dynamic> json) {
    return MoodRecord(
      objectId: (json['objectId'] ?? json['id'] ?? '').toString(),
      relationId: (json['relationId'] ?? '').toString(),
      userId: (json['userId'] ?? '').toString(),
      moodType: MoodType.fromString(json['moodType']?.toString()),
      moodScore: (json['moodScore'] as num?)?.toInt() ?? 3,
      content: json['content']?.toString(),
      imageUrls: (json['imageUrls'] as List<dynamic>? ?? const <dynamic>[])
          .map((item) => item.toString())
          .toList(),
      visibleToPartner: json['visibleToPartner'] != false,
      recordDate: _parseDateTime(json['recordDate']) ?? DateTime.now(),
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
      'userId': userId,
      'moodType': moodType.name,
      'moodScore': moodScore,
      'content': content,
      'imageUrls': imageUrls,
      'visibleToPartner': visibleToPartner,
      'recordDate': recordDate.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

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

extension MoodTypeX on MoodType {
  String get label {
    switch (this) {
      case MoodType.happy:
        return '开心';
      case MoodType.excited:
        return '兴奋';
      case MoodType.calm:
        return '平静';
      case MoodType.worried:
        return '担心';
      case MoodType.sad:
        return '难过';
      case MoodType.angry:
        return '生气';
    }
  }

  String get emoji {
    switch (this) {
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
}

extension MoodRecordX on MoodRecord {
  String get moodEmoji => moodType.emoji;

  String? get contentPreview {
    final text = content?.trim();
    if (text == null || text.isEmpty) {
      return null;
    }
    if (text.length <= 40) {
      return text;
    }
    return '${text.substring(0, 40)}...';
  }
}

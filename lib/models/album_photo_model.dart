import 'package:equatable/equatable.dart';

/// 相册可见范围
enum AlbumVisibility {
  both,
  private;

  static AlbumVisibility fromString(String? value) {
    return AlbumVisibility.values.firstWhere(
      (item) => item.name == value,
      orElse: () => AlbumVisibility.both,
    );
  }
}

/// 相册照片模型
class AlbumPhoto extends Equatable {
  final String objectId;
  final String relationId;
  final String uploaderId;
  final String photoUrl;
  final String thumbnailUrl;
  final String? caption;
  final DateTime? shotAt;
  final String? locationText;
  final List<String> tags;
  final AlbumVisibility visibility;
  final DateTime createdAt;

  const AlbumPhoto({
    required this.objectId,
    required this.relationId,
    required this.uploaderId,
    required this.photoUrl,
    required this.thumbnailUrl,
    this.caption,
    this.shotAt,
    this.locationText,
    this.tags = const <String>[],
    required this.visibility,
    required this.createdAt,
  });

  factory AlbumPhoto.fromJson(Map<String, dynamic> json) {
    return AlbumPhoto(
      objectId: (json['objectId'] ?? json['id'] ?? '').toString(),
      relationId: (json['relationId'] ?? '').toString(),
      uploaderId: (json['uploaderId'] ?? '').toString(),
      photoUrl: (json['photoUrl'] ?? '').toString(),
      thumbnailUrl: (json['thumbnailUrl'] ?? '').toString(),
      caption: json['caption']?.toString(),
      shotAt: _parseDateTime(json['shotAt']),
      locationText: json['locationText']?.toString(),
      tags: (json['tags'] as List<dynamic>? ?? const <dynamic>[])
          .map((tag) => tag.toString())
          .toList(),
      visibility: AlbumVisibility.fromString(json['visibility']?.toString()),
      createdAt: _parseDateTime(json['createdAt']) ?? DateTime.now(),
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
      'uploaderId': uploaderId,
      'photoUrl': photoUrl,
      'thumbnailUrl': thumbnailUrl,
      'caption': caption,
      'shotAt': shotAt?.toIso8601String(),
      'locationText': locationText,
      'tags': tags,
      'visibility': visibility.name,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  AlbumPhoto copyWith({
    String? objectId,
    String? relationId,
    String? uploaderId,
    String? photoUrl,
    String? thumbnailUrl,
    String? caption,
    DateTime? shotAt,
    String? locationText,
    List<String>? tags,
    AlbumVisibility? visibility,
    DateTime? createdAt,
  }) {
    return AlbumPhoto(
      objectId: objectId ?? this.objectId,
      relationId: relationId ?? this.relationId,
      uploaderId: uploaderId ?? this.uploaderId,
      photoUrl: photoUrl ?? this.photoUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      caption: caption ?? this.caption,
      shotAt: shotAt ?? this.shotAt,
      locationText: locationText ?? this.locationText,
      tags: tags ?? this.tags,
      visibility: visibility ?? this.visibility,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        objectId,
        relationId,
        uploaderId,
        photoUrl,
        thumbnailUrl,
        caption,
        shotAt,
        locationText,
        tags,
        visibility,
        createdAt,
      ];
}

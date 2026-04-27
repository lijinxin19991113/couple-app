import 'package:equatable/equatable.dart';

/// 相册照片可见性
enum PhotoVisibility { both, private }

/// 相册照片模型
class AlbumPhotoModel extends Equatable {
  /// 照片 ID
  final String objectId;

  /// 情侣关系 ID
  final String relationId;

  /// 上传者用户 ID
  final String uploaderId;

  /// 上传者名称（冗余字段，便于展示）
  final String? uploaderName;

  /// 照片 URL
  final String photoUrl;

  /// 缩略图 URL
  final String? thumbnailUrl;

  /// 文案描述
  final String? caption;

  /// 拍摄时间
  final DateTime? shotAt;

  /// 位置文本
  final String? locationText;

  /// 标签列表
  final List<String> tags;

  /// 可见性：both-双方可见，private-仅自己可见
  final PhotoVisibility visibility;

  /// 创建时间
  final DateTime createdAt;

  const AlbumPhotoModel({
    required this.objectId,
    required this.relationId,
    required this.uploaderId,
    this.uploaderName,
    required this.photoUrl,
    this.thumbnailUrl,
    this.caption,
    this.shotAt,
    this.locationText,
    this.tags = const [],
    required this.visibility,
    required this.createdAt,
  });

  /// 从 JSON 创建（带类型守卫）
  factory AlbumPhotoModel.fromJson(Map<String, dynamic> json) {
    return AlbumPhotoModel(
      objectId: json['objectId'] ?? json['id'] ?? '',
      relationId: json['relationId'] ?? '',
      uploaderId: json['uploaderId'] ?? '',
      uploaderName: json['uploaderName'],
      photoUrl: json['photoUrl'] ?? '',
      thumbnailUrl: json['thumbnailUrl'],
      caption: json['caption'],
      shotAt: _parseDateTime(json['shotAt']),
      locationText: json['locationText'],
      tags: _parseTags(json['tags']),
      visibility: _parseVisibility(json['visibility']),
      createdAt: _parseDateTime(json['createdAt']) ?? DateTime.now(),
    );
  }

  /// 解析日期时间（类型守卫）
  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value);
    }
    return null;
  }

  /// 解析标签列表
  static List<String> _parseTags(dynamic value) {
    if (value == null) return [];
    if (value is List) {
      return value.map((e) => e.toString()).toList();
    }
    return [];
  }

  /// 解析可见性
  static PhotoVisibility _parseVisibility(dynamic value) {
    if (value == null) return PhotoVisibility.both;
    if (value is String) {
      return value == 'private' ? PhotoVisibility.private : PhotoVisibility.both;
    }
    if (value is PhotoVisibility) return value;
    return PhotoVisibility.both;
  }

  /// 可见性转字符串
  String visibilityToString() {
    return visibility == PhotoVisibility.private ? 'private' : 'both';
  }

  /// 可见性转中文描述
  String get visibilityText {
    return visibility == PhotoVisibility.private ? '仅自己可见' : '双方可见';
  }

  /// 转为 JSON
  Map<String, dynamic> toJson() {
    return {
      'objectId': objectId,
      'relationId': relationId,
      'uploaderId': uploaderId,
      'uploaderName': uploaderName,
      'photoUrl': photoUrl,
      'thumbnailUrl': thumbnailUrl,
      'caption': caption,
      'shotAt': shotAt?.toIso8601String(),
      'locationText': locationText,
      'tags': tags,
      'visibility': visibilityToString(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// 复制并修改
  AlbumPhotoModel copyWith({
    String? objectId,
    String? relationId,
    String? uploaderId,
    String? uploaderName,
    String? photoUrl,
    String? thumbnailUrl,
    String? caption,
    DateTime? shotAt,
    String? locationText,
    List<String>? tags,
    PhotoVisibility? visibility,
    DateTime? createdAt,
  }) {
    return AlbumPhotoModel(
      objectId: objectId ?? this.objectId,
      relationId: relationId ?? this.relationId,
      uploaderId: uploaderId ?? this.uploaderId,
      uploaderName: uploaderName ?? this.uploaderName,
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
        uploaderName,
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

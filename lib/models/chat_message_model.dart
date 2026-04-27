import 'package:equatable/equatable.dart';

/// 消息类型
enum MessageType {
  text,
  image,
  emoji,
  system;

  static MessageType fromString(String? value) {
    return MessageType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => MessageType.text,
    );
  }
}

/// 发送状态
enum SendStatus {
  sending,
  sent,
  failed,
  read;

  static SendStatus fromString(String? value) {
    return SendStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => SendStatus.sending,
    );
  }
}

/// 聊天消息模型
class ChatMessage extends Equatable {
  /// 消息 ID
  final String objectId;

  /// 客户端消息 ID（用于去重和关联）
  final String clientMsgId;

  /// 关系 ID
  final String relationId;

  /// 发送者 ID
  final String senderId;

  /// 接收者 ID
  final String receiverId;

  /// 消息类型
  final MessageType messageType;

  /// 消息内容（文字消息时使用）
  final String? content;

  /// 媒体 URL（图片/语音消息时使用）
  final String? mediaUrl;

  /// 媒体缩略图 URL
  final String? mediaThumbnailUrl;

  /// 媒体宽度
  final int? mediaWidth;

  /// 媒体高度
  final int? mediaHeight;

  /// 位置地址
  final String? locationAddress;

  /// 位置纬度
  final double? locationLat;

  /// 位置经度
  final double? locationLng;

  /// 发送状态
  final SendStatus sendStatus;

  /// 已读时间
  final DateTime? readAt;

  /// 创建时间
  final DateTime createdAt;

  const ChatMessage({
    required this.objectId,
    required this.clientMsgId,
    required this.relationId,
    required this.senderId,
    required this.receiverId,
    required this.messageType,
    this.content,
    this.mediaUrl,
    this.mediaThumbnailUrl,
    this.mediaWidth,
    this.mediaHeight,
    this.locationAddress,
    this.locationLat,
    this.locationLng,
    required this.sendStatus,
    this.readAt,
    required this.createdAt,
  });

  /// 从 JSON 创建
  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    final messageTypeStr = json['messageType'] as String?;
    final sendStatusStr = json['sendStatus'] as String?;

    return ChatMessage(
      objectId: json['objectId'] ?? json['id'] ?? '',
      clientMsgId: json['clientMsgId'] ?? '',
      relationId: json['relationId'] ?? '',
      senderId: json['senderId'] ?? '',
      receiverId: json['receiverId'] ?? '',
      messageType: MessageType.fromString(messageTypeStr),
      content: json['content'] as String?,
      mediaUrl: json['mediaUrl'] as String?,
      mediaThumbnailUrl: json['mediaThumbnailUrl'] as String?,
      mediaWidth: (json['mediaWidth'] as num?)?.toInt(),
      mediaHeight: (json['mediaHeight'] as num?)?.toInt(),
      locationAddress: json['locationAddress'] as String?,
      locationLat: (json['locationLat'] as num?)?.toDouble(),
      locationLng: (json['locationLng'] as num?)?.toDouble(),
      sendStatus: SendStatus.fromString(sendStatusStr),
      readAt: _parseDateTime(json['readAt']),
      createdAt: _parseDateTime(json['createdAt']) ?? DateTime.now(),
    );
  }

  /// 安全解析 DateTime
  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  /// 转为 JSON
  Map<String, dynamic> toJson() {
    return {
      'objectId': objectId,
      'clientMsgId': clientMsgId,
      'relationId': relationId,
      'senderId': senderId,
      'receiverId': receiverId,
      'messageType': messageType.name,
      'content': content,
      'mediaUrl': mediaUrl,
      'mediaThumbnailUrl': mediaThumbnailUrl,
      'mediaWidth': mediaWidth,
      'mediaHeight': mediaHeight,
      'locationAddress': locationAddress,
      'locationLat': locationLat,
      'locationLng': locationLng,
      'sendStatus': sendStatus.name,
      'readAt': readAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// 复制并修改
  ChatMessage copyWith({
    String? objectId,
    String? clientMsgId,
    String? relationId,
    String? senderId,
    String? receiverId,
    MessageType? messageType,
    String? content,
    String? mediaUrl,
    String? mediaThumbnailUrl,
    int? mediaWidth,
    int? mediaHeight,
    String? locationAddress,
    double? locationLat,
    double? locationLng,
    SendStatus? sendStatus,
    DateTime? readAt,
    DateTime? createdAt,
  }) {
    return ChatMessage(
      objectId: objectId ?? this.objectId,
      clientMsgId: clientMsgId ?? this.clientMsgId,
      relationId: relationId ?? this.relationId,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      messageType: messageType ?? this.messageType,
      content: content ?? this.content,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      mediaThumbnailUrl: mediaThumbnailUrl ?? this.mediaThumbnailUrl,
      mediaWidth: mediaWidth ?? this.mediaWidth,
      mediaHeight: mediaHeight ?? this.mediaHeight,
      locationAddress: locationAddress ?? this.locationAddress,
      locationLat: locationLat ?? this.locationLat,
      locationLng: locationLng ?? this.locationLng,
      sendStatus: sendStatus ?? this.sendStatus,
      readAt: readAt ?? this.readAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        objectId,
        clientMsgId,
        relationId,
        senderId,
        receiverId,
        messageType,
        content,
        mediaUrl,
        mediaThumbnailUrl,
        mediaWidth,
        mediaHeight,
        locationAddress,
        locationLat,
        locationLng,
        sendStatus,
        readAt,
        createdAt,
      ];
}

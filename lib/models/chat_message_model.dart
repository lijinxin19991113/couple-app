import 'package:equatable/equatable.dart';

/// 聊天消息类型
enum ChatMessageType {
  text,
  image,
  emoji,
  system;

  static ChatMessageType fromString(String? value) {
    return ChatMessageType.values.firstWhere(
      (item) => item.name == value,
      orElse: () => ChatMessageType.text,
    );
  }
}

/// 消息发送状态
enum ChatSendStatus {
  sending,
  sent,
  failed,
  read;

  static ChatSendStatus fromString(String? value) {
    return ChatSendStatus.values.firstWhere(
      (item) => item.name == value,
      orElse: () => ChatSendStatus.sending,
    );
  }
}

/// 聊天消息模型
class ChatMessage extends Equatable {
  final String objectId;
  final String clientMsgId;
  final String relationId;
  final String senderId;
  final String receiverId;
  final ChatMessageType messageType;
  final String? content;
  final String? mediaUrl;
  final String? mediaThumbnailUrl;
  final int? mediaWidth;
  final int? mediaHeight;
  final String? locationAddress;
  final double? locationLat;
  final double? locationLng;
  final ChatSendStatus sendStatus;
  final DateTime? readAt;
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

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      objectId: (json['objectId'] ?? json['id'] ?? '').toString(),
      clientMsgId: (json['clientMsgId'] ?? '').toString(),
      relationId: (json['relationId'] ?? '').toString(),
      senderId: (json['senderId'] ?? '').toString(),
      receiverId: (json['receiverId'] ?? '').toString(),
      messageType: ChatMessageType.fromString(json['messageType']?.toString()),
      content: json['content']?.toString(),
      mediaUrl: json['mediaUrl']?.toString(),
      mediaThumbnailUrl: json['mediaThumbnailUrl']?.toString(),
      mediaWidth: (json['mediaWidth'] as num?)?.toInt(),
      mediaHeight: (json['mediaHeight'] as num?)?.toInt(),
      locationAddress: json['locationAddress']?.toString(),
      locationLat: (json['locationLat'] as num?)?.toDouble(),
      locationLng: (json['locationLng'] as num?)?.toDouble(),
      sendStatus: ChatSendStatus.fromString(json['sendStatus']?.toString()),
      readAt: _parseDateTime(json['readAt']),
      createdAt: _parseDateTime(json['createdAt']) ?? DateTime.now(),
    );
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is DateTime) {
      return value;
    }
    if (value is String) {
      return DateTime.tryParse(value);
    }
    return null;
  }

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

  ChatMessage copyWith({
    String? objectId,
    String? clientMsgId,
    String? relationId,
    String? senderId,
    String? receiverId,
    ChatMessageType? messageType,
    String? content,
    String? mediaUrl,
    String? mediaThumbnailUrl,
    int? mediaWidth,
    int? mediaHeight,
    String? locationAddress,
    double? locationLat,
    double? locationLng,
    ChatSendStatus? sendStatus,
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

import 'package:equatable/equatable.dart';

/// 消息发送状态
enum MessageStatus { sending, sent, failed, read }

/// 消息类型
enum MessageType { text, image, emoji, location, system }

/// 聊天消息模型
class MessageModel extends Equatable {
  /// 消息 ID
  final String id;

  /// 情侣关系 ID
  final String relationId;

  /// 发送者用户 ID
  final String senderId;

  /// 接收者用户 ID
  final String receiverId;

  /// 消息类型
  final MessageType type;

  /// 文本内容
  final String? content;

  /// 媒体文件 URL（图片等）
  final String? mediaUrl;

  /// 缩略图 URL
  final String? thumbnailUrl;

  /// 扩展数据（如图片尺寸、位置信息）
  final Map<String, dynamic>? extraData;

  /// 发送状态
  final MessageStatus status;

  /// 已读时间
  final DateTime? readAt;

  /// 客户端消息 ID（用于去重）
  final String? clientMsgId;

  /// 创建时间
  final DateTime createdAt;

  const MessageModel({
    required this.id,
    required this.relationId,
    required this.senderId,
    required this.receiverId,
    required this.type,
    this.content,
    this.mediaUrl,
    this.thumbnailUrl,
    this.extraData,
    required this.status,
    this.readAt,
    this.clientMsgId,
    required this.createdAt,
  });

  /// 从 JSON 创建
  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] ?? json['objectId'] ?? '',
      relationId: json['relationId'] ?? '',
      senderId: json['senderId'] ?? '',
      receiverId: json['receiverId'] ?? '',
      type: _parseType(json['messageType'] ?? json['type']),
      content: json['content'],
      mediaUrl: json['mediaFile'] ?? json['mediaUrl'],
      thumbnailUrl: json['thumbnailUrl'],
      extraData: json['extraData'],
      status: _parseStatus(json['sendStatus']),
      readAt: (json['readAt'] is String)
          ? DateTime.tryParse(json['readAt'])
          : null,
      clientMsgId: json['clientMsgId'],
      createdAt: (json['createdAt'] is String)
          ? DateTime.tryParse(json['createdAt']) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  /// 解析消息类型
  static MessageType _parseType(String? type) {
    switch (type) {
      case 'image':
        return MessageType.image;
      case 'emoji':
        return MessageType.emoji;
      case 'location':
        return MessageType.location;
      case 'system':
        return MessageType.system;
      default:
        return MessageType.text;
    }
  }

  /// 解析消息状态
  static MessageStatus _parseStatus(String? status) {
    switch (status) {
      case 'sending':
        return MessageStatus.sending;
      case 'sent':
        return MessageStatus.sent;
      case 'failed':
        return MessageStatus.failed;
      case 'read':
        return MessageStatus.read;
      default:
        return MessageStatus.sending;
    }
  }

  /// 消息类型转字符串
  String typeToString() {
    switch (type) {
      case MessageType.text:
        return 'text';
      case MessageType.image:
        return 'image';
      case MessageType.emoji:
        return 'emoji';
      case MessageType.location:
        return 'location';
      case MessageType.system:
        return 'system';
    }
  }

  /// 消息状态转字符串
  String statusToString() {
    switch (status) {
      case MessageStatus.sending:
        return 'sending';
      case MessageStatus.sent:
        return 'sent';
      case MessageStatus.failed:
        return 'failed';
      case MessageStatus.read:
        return 'read';
    }
  }

  /// 转为 JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'relationId': relationId,
      'senderId': senderId,
      'receiverId': receiverId,
      'messageType': typeToString(),
      'content': content,
      'mediaFile': mediaUrl,
      'thumbnailUrl': thumbnailUrl,
      'extraData': extraData,
      'sendStatus': statusToString(),
      'readAt': readAt?.toIso8601String(),
      'clientMsgId': clientMsgId,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// 复制并修改
  MessageModel copyWith({
    String? id,
    String? relationId,
    String? senderId,
    String? receiverId,
    MessageType? type,
    String? content,
    String? mediaUrl,
    String? thumbnailUrl,
    Map<String, dynamic>? extraData,
    MessageStatus? status,
    DateTime? readAt,
    String? clientMsgId,
    DateTime? createdAt,
  }) {
    return MessageModel(
      id: id ?? this.id,
      relationId: relationId ?? this.relationId,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      type: type ?? this.type,
      content: content ?? this.content,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      extraData: extraData ?? this.extraData,
      status: status ?? this.status,
      readAt: readAt ?? this.readAt,
      clientMsgId: clientMsgId ?? this.clientMsgId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        relationId,
        senderId,
        receiverId,
        type,
        content,
        mediaUrl,
        thumbnailUrl,
        extraData,
        status,
        readAt,
        clientMsgId,
        createdAt,
      ];
}

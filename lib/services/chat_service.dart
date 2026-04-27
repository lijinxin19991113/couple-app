import 'dart:async';

import '../models/chat_message_model.dart';

/// 聊天服务
class ChatService {
  // 模拟数据存储
  final Map<String, List<ChatMessage>> _mockMessages = {};
  final Map<String, StreamController<ChatMessage>> _messageStreams = {};

  /// 获取聊天消息
  Future<List<ChatMessage>> getChatMessages(
    String relationId, {
    DateTime? beforeTime,
    int limit = 20,
  }) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 500));

    final messages = _mockMessages[relationId] ?? [];

    // 过滤时间之前的消息
    var filtered = messages;
    if (beforeTime != null) {
      filtered = messages.where((m) => m.createdAt.isBefore(beforeTime)).toList();
    }

    // 按时间倒序，返回指定数量
    filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return filtered.take(limit).toList().reversed.toList();
  }

  /// 发送文本消息
  Future<ChatMessage> sendTextMessage(
    String relationId,
    String content, {
    required String senderId,
    required String receiverId,
  }) async {
    final clientMsgId = 'msg_${DateTime.now().millisecondsSinceEpoch}';
    final message = ChatMessage(
      objectId: clientMsgId,
      clientMsgId: clientMsgId,
      relationId: relationId,
      senderId: senderId,
      receiverId: receiverId,
      messageType: ChatMessageType.text,
      content: content,
      sendStatus: ChatSendStatus.sending,
      createdAt: DateTime.now(),
    );

    // 添加到本地存储
    _mockMessages.putIfAbsent(relationId, () => []);
    _mockMessages[relationId]!.add(message);

    // 模拟发送成功
    await Future.delayed(const Duration(milliseconds: 300));

    final sentMessage = message.copyWith(sendStatus: ChatSendStatus.sent);
    _updateMessage(relationId, clientMsgId, sentMessage);

    // 通知新消息
    _notifyNewMessage(relationId, sentMessage);

    return sentMessage;
  }

  /// 发送图片消息
  Future<ChatMessage> sendImageMessage(
    String relationId,
    String localFilePath, {
    String? caption,
    required String senderId,
    required String receiverId,
  }) async {
    final clientMsgId = 'msg_${DateTime.now().millisecondsSinceEpoch}';
    final message = ChatMessage(
      objectId: clientMsgId,
      clientMsgId: clientMsgId,
      relationId: relationId,
      senderId: senderId,
      receiverId: receiverId,
      messageType: ChatMessageType.image,
      content: caption,
      mediaUrl: localFilePath, // 模拟上传后返回 URL
      sendStatus: ChatSendStatus.sending,
      createdAt: DateTime.now(),
    );

    // 添加到本地存储
    _mockMessages.putIfAbsent(relationId, () => []);
    _mockMessages[relationId]!.add(message);

    // 模拟上传延迟
    await Future.delayed(const Duration(seconds: 1));

    final sentMessage = message.copyWith(sendStatus: ChatSendStatus.sent);
    _updateMessage(relationId, clientMsgId, sentMessage);

    // 通知新消息
    _notifyNewMessage(relationId, sentMessage);

    return sentMessage;
  }

  /// 将消息标记为已读
  Future<void> markMessagesAsRead(String relationId, String lastReadMsgId) async {
    await Future.delayed(const Duration(milliseconds: 100));

    final messages = _mockMessages[relationId];
    if (messages == null) return;

    for (var i = 0; i < messages.length; i++) {
      if (messages[i].objectId == lastReadMsgId ||
          messages[i].clientMsgId == lastReadMsgId) {
        // 标记此消息及之前的所有消息为已读
        for (var j = 0; j <= i; j++) {
          if (messages[j].sendStatus != ChatSendStatus.read) {
            messages[j] = messages[j].copyWith(
              sendStatus: ChatSendStatus.read,
              readAt: DateTime.now(),
            );
          }
        }
        break;
      }
    }
  }

  /// 获取未读消息数量
  Future<int> getUnreadCount(String relationId) async {
    await Future.delayed(const Duration(milliseconds: 100));

    final messages = _mockMessages[relationId] ?? [];
    return messages.where((m) => m.sendStatus != ChatSendStatus.read).length;
  }

  /// 监听新消息
  Stream<ChatMessage> observeNewMessages(String relationId) {
    _messageStreams.putIfAbsent(
      relationId,
      () => StreamController<ChatMessage>.broadcast(),
    );
    return _messageStreams[relationId]!.stream;
  }

  /// 通知新消息
  void _notifyNewMessage(String relationId, ChatMessage message) {
    final stream = _messageStreams[relationId];
    if (stream != null && !stream.isClosed) {
      stream.add(message);
    }
  }

  /// 更新消息
  void _updateMessage(String relationId, String clientMsgId, ChatMessage newMessage) {
    final messages = _mockMessages[relationId];
    if (messages == null) return;

    final index = messages.indexWhere((m) => m.clientMsgId == clientMsgId);
    if (index != -1) {
      messages[index] = newMessage;
    }
  }

  /// 模拟收到对方消息（用于测试）
  Future<void> simulateIncomingMessage(
    String relationId,
    String senderId,
    String receiverId,
    String content,
  ) async {
    await Future.delayed(const Duration(seconds: 2));

    final clientMsgId = 'msg_${DateTime.now().millisecondsSinceEpoch}';
    final message = ChatMessage(
      objectId: clientMsgId,
      clientMsgId: clientMsgId,
      relationId: relationId,
      senderId: senderId,
      receiverId: receiverId,
      messageType: ChatMessageType.text,
      content: content,
      sendStatus: ChatSendStatus.sent,
      createdAt: DateTime.now(),
    );

    _mockMessages.putIfAbsent(relationId, () => []);
    _mockMessages[relationId]!.add(message);

    _notifyNewMessage(relationId, message);
  }

  /// 释放资源
  void dispose() {
    for (final stream in _messageStreams.values) {
      stream.close();
    }
    _messageStreams.clear();
  }
}

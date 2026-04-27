import 'dart:async';

import '../models/chat_message_model.dart';

/// 聊天服务（当前为 Mock 实现）
class ChatService {
  final Map<String, List<ChatMessage>> _messageStore = <String, List<ChatMessage>>{};
  final Map<String, StreamController<ChatMessage>> _streamStore =
      <String, StreamController<ChatMessage>>{};

  ChatService() {
    _bootstrapMockData();
  }

  Future<List<ChatMessage>> getChatMessages(
    String relationId, {
    DateTime? beforeTime,
    int limit = 30,
  }) async {
    await Future.delayed(const Duration(milliseconds: 280));

    final source = List<ChatMessage>.from(_messageStore[relationId] ?? <ChatMessage>[])
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

    final filtered = beforeTime == null
        ? source
        : source.where((item) => item.createdAt.isBefore(beforeTime)).toList();

    if (filtered.length <= limit) {
      return filtered;
    }
    return filtered.sublist(filtered.length - limit);
  }

  Future<ChatMessage> sendTextMessage({
    required String relationId,
    required String senderId,
    required String receiverId,
    required String content,
  }) async {
    final now = DateTime.now();
    final tempId = 'tmp_${now.microsecondsSinceEpoch}';
    var message = ChatMessage(
      objectId: tempId,
      clientMsgId: tempId,
      relationId: relationId,
      senderId: senderId,
      receiverId: receiverId,
      messageType: ChatMessageType.text,
      content: content,
      sendStatus: ChatSendStatus.sending,
      createdAt: now,
    );

    _appendMessage(relationId, message);

    await Future.delayed(const Duration(milliseconds: 380));

    if (content.contains('fail')) {
      message = message.copyWith(sendStatus: ChatSendStatus.failed);
      _replaceMessage(relationId, message);
      return message;
    }

    message = message.copyWith(
      objectId: 'msg_${now.millisecondsSinceEpoch}',
      sendStatus: ChatSendStatus.sent,
    );
    _replaceMessage(relationId, message);
    _notify(relationId, message);
    return message;
  }

  Future<ChatMessage> sendImageMessage({
    required String relationId,
    required String senderId,
    required String receiverId,
    required String localPath,
    String? caption,
  }) async {
    final now = DateTime.now();
    final tempId = 'tmp_img_${now.microsecondsSinceEpoch}';
    var message = ChatMessage(
      objectId: tempId,
      clientMsgId: tempId,
      relationId: relationId,
      senderId: senderId,
      receiverId: receiverId,
      messageType: ChatMessageType.image,
      content: caption,
      mediaUrl: localPath,
      mediaThumbnailUrl: localPath,
      mediaWidth: 960,
      mediaHeight: 1280,
      sendStatus: ChatSendStatus.sending,
      createdAt: now,
    );

    _appendMessage(relationId, message);

    await Future.delayed(const Duration(milliseconds: 750));

    if (localPath.contains('fail')) {
      message = message.copyWith(sendStatus: ChatSendStatus.failed);
      _replaceMessage(relationId, message);
      return message;
    }

    message = message.copyWith(
      objectId: 'img_${now.millisecondsSinceEpoch}',
      sendStatus: ChatSendStatus.sent,
      mediaUrl:
          'https://images.unsplash.com/photo-1516589178581-6cd7833ae3b2?auto=format&fit=crop&w=900&q=80',
      mediaThumbnailUrl:
          'https://images.unsplash.com/photo-1516589178581-6cd7833ae3b2?auto=format&fit=crop&w=360&q=80',
    );
    _replaceMessage(relationId, message);
    _notify(relationId, message);
    return message;
  }

  Future<void> markMessagesAsRead({
    required String relationId,
    required String readerId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 160));

    final list = _messageStore[relationId];
    if (list == null) {
      return;
    }
    final now = DateTime.now();

    for (var i = 0; i < list.length; i++) {
      final item = list[i];
      if (item.receiverId == readerId && item.sendStatus != ChatSendStatus.read) {
        list[i] = item.copyWith(sendStatus: ChatSendStatus.read, readAt: now);
      }
    }
  }

  Future<int> getUnreadCount({
    required String relationId,
    required String receiverId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 120));

    final list = _messageStore[relationId] ?? <ChatMessage>[];
    return list
        .where((item) =>
            item.receiverId == receiverId && item.sendStatus != ChatSendStatus.read)
        .length;
  }

  Stream<ChatMessage> observeNewMessages(String relationId) {
    _streamStore.putIfAbsent(
      relationId,
      () => StreamController<ChatMessage>.broadcast(),
    );
    return _streamStore[relationId]!.stream;
  }

  void _appendMessage(String relationId, ChatMessage message) {
    _messageStore.putIfAbsent(relationId, () => <ChatMessage>[]);
    _messageStore[relationId]!.add(message);
  }

  void _replaceMessage(String relationId, ChatMessage message) {
    final list = _messageStore[relationId];
    if (list == null) {
      return;
    }
    final index = list.indexWhere((item) => item.clientMsgId == message.clientMsgId);
    if (index >= 0) {
      list[index] = message;
    }
  }

  void _notify(String relationId, ChatMessage message) {
    final controller = _streamStore[relationId];
    if (controller != null && !controller.isClosed) {
      controller.add(message);
    }
  }

  void _bootstrapMockData() {
    const relationId = 'relation_001';
    _messageStore[relationId] = <ChatMessage>[
      ChatMessage(
        objectId: 'msg_1',
        clientMsgId: 'msg_1',
        relationId: relationId,
        senderId: 'user_partner',
        receiverId: 'mock_user_001',
        messageType: ChatMessageType.text,
        content: '今天下班一起吃火锅吗？',
        sendStatus: ChatSendStatus.sent,
        createdAt: DateTime(2026, 4, 27, 18, 20),
      ),
      ChatMessage(
        objectId: 'msg_2',
        clientMsgId: 'msg_2',
        relationId: relationId,
        senderId: 'mock_user_001',
        receiverId: 'user_partner',
        messageType: ChatMessageType.text,
        content: '好呀，我先去排队～',
        sendStatus: ChatSendStatus.read,
        readAt: DateTime(2026, 4, 27, 18, 26),
        createdAt: DateTime(2026, 4, 27, 18, 22),
      ),
      ChatMessage(
        objectId: 'msg_3',
        clientMsgId: 'msg_3',
        relationId: relationId,
        senderId: 'user_partner',
        receiverId: 'mock_user_001',
        messageType: ChatMessageType.image,
        content: '路上看到超可爱的云',
        mediaUrl:
            'https://images.unsplash.com/photo-1534088568595-a066f410bcda?auto=format&fit=crop&w=900&q=80',
        mediaThumbnailUrl:
            'https://images.unsplash.com/photo-1534088568595-a066f410bcda?auto=format&fit=crop&w=320&q=80',
        mediaWidth: 900,
        mediaHeight: 1200,
        sendStatus: ChatSendStatus.sent,
        createdAt: DateTime(2026, 4, 27, 18, 30),
      ),
    ];
  }

  void dispose() {
    for (final controller in _streamStore.values) {
      controller.close();
    }
    _streamStore.clear();
  }
}

import 'dart:async';

import 'package:get/get.dart';

import '../models/chat_message_model.dart';
import '../services/chat_service.dart';
import 'user_controller.dart';

/// 聊天控制器
class ChatController extends GetxController {
  late final ChatService _chatService;
  late final UserController _userController;

  /// 消息列表
  final RxList<ChatMessage> messages = <ChatMessage>[].obs;

  /// 是否正在加载
  final RxBool isLoading = false.obs;

  /// 未读消息数量
  final RxInt unreadCount = 0.obs;

  /// 是否正在发送
  final RxBool isSending = false.obs;

  /// 当前关系 ID
  String? _currentRelationId;

  /// 新消息订阅
  StreamSubscription<ChatMessage>? _messageSubscription;

  /// 是否已挂载
  bool _isMounted = false;

  @override
  void onInit() {
    super.onInit();
    _chatService = ChatService();
    _userController = Get.find<UserController>();
    _isMounted = true;
  }

  @override
  void onClose() {
    _messageSubscription?.cancel();
    _chatService.dispose();
    _isMounted = false;
    super.onClose();
  }

  /// 加载消息列表
  Future<void> loadMessages({String? relationId}) async {
    if (!_isMounted) return;

    final relation = relationId ?? _userController.coupleRelation.value?.id;
    if (relation == null) return;

    _currentRelationId = relation;
    isLoading.value = true;

    try {
      final result = await _chatService.getChatMessages(relation);
      if (_isMounted) {
        messages.value = result;
      }
    } catch (e) {
      if (_isMounted) {
        // 处理错误
      }
    } finally {
      if (_isMounted) {
        isLoading.value = false;
      }
    }
  }

  /// 发送文本消息
  Future<bool> sendTextMessage(String content) async {
    if (!_isMounted) return false;

    final relation = _userController.coupleRelation.value?.id;
    final currentUser = _userController.currentUser.value;
    final partner = _userController.coupleRelation.value?.partner;

    if (relation == null || currentUser == null || partner == null) {
      return false;
    }

    if (content.trim().isEmpty) return false;

    isSending.value = true;

    try {
      final message = await _chatService.sendTextMessage(
        relation,
        content.trim(),
        senderId: currentUser.id,
        receiverId: partner.id,
      );

      if (_isMounted) {
        messages.add(message);
        return true;
      }
      return false;
    } catch (e) {
      if (_isMounted) {
        return false;
      }
      return false;
    } finally {
      if (_isMounted) {
        isSending.value = false;
      }
    }
  }

  /// 发送图片消息
  Future<bool> sendImageMessage(String localFilePath, {String? caption}) async {
    if (!_isMounted) return false;

    final relation = _userController.coupleRelation.value?.id;
    final currentUser = _userController.currentUser.value;
    final partner = _userController.coupleRelation.value?.partner;

    if (relation == null || currentUser == null || partner == null) {
      return false;
    }

    isSending.value = true;

    try {
      final message = await _chatService.sendImageMessage(
        relation,
        localFilePath,
        caption: caption,
        senderId: currentUser.id,
        receiverId: partner.id,
      );

      if (_isMounted) {
        messages.add(message);
        return true;
      }
      return false;
    } catch (e) {
      if (_isMounted) {
        return false;
      }
      return false;
    } finally {
      if (_isMounted) {
        isSending.value = false;
      }
    }
  }

  /// 标记消息为已读
  Future<void> markAsRead({String? lastReadMsgId}) async {
    if (!_isMounted) return;

    final relation = _userController.coupleRelation.value?.id;
    if (relation == null) return;

    try {
      if (lastReadMsgId != null) {
        await _chatService.markMessagesAsRead(relation, lastReadMsgId);
      }

      // 更新本地未读数
      if (_isMounted) {
        await refreshUnreadCount();
      }
    } catch (e) {
      // 处理错误
    }
  }

  /// 刷新未读数量
  Future<void> refreshUnreadCount() async {
    if (!_isMounted) return;

    final relation = _userController.coupleRelation.value?.id;
    if (relation == null) return;

    try {
      final count = await _chatService.getUnreadCount(relation);
      if (_isMounted) {
        unreadCount.value = count;
      }
    } catch (e) {
      // 处理错误
    }
  }

  /// 监听新消息
  void listenNewMessages() {
    final relation = _userController.coupleRelation.value?.id;
    if (relation == null) return;

    _messageSubscription?.cancel();
    _messageSubscription = _chatService.observeNewMessages(relation).listen(
      (message) {
        if (_isMounted) {
          // 避免重复添加
          final exists = messages.any(
            (m) => m.clientMsgId == message.clientMsgId,
          );
          if (!exists) {
            messages.add(message);
          }
        }
      },
      onError: (e) {
        // 处理错误
      },
    );
  }

  /// 停止监听新消息
  void stopListeningNewMessages() {
    _messageSubscription?.cancel();
    _messageSubscription = null;
  }

  /// 重试发送失败的消息
  Future<void> retrySendMessage(ChatMessage message) async {
    if (!_isMounted) return;

    // 更新消息状态为发送中
    final index = messages.indexWhere((m) => m.clientMsgId == message.clientMsgId);
    if (index == -1) return;

    messages[index] = message.copyWith(sendStatus: ChatSendStatus.sending);

    try {
      if (message.messageType == ChatMessageType.text) {
        await sendTextMessage(message.content ?? '');
      } else if (message.messageType == ChatMessageType.image) {
        await sendImageMessage(message.mediaUrl ?? '', caption: message.content);
      }
    } catch (e) {
      if (_isMounted) {
        messages[index] = message.copyWith(sendStatus: ChatSendStatus.failed);
      }
    }
  }
}

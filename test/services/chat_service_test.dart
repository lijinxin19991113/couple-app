import 'package:flutter_test/flutter_test.dart';
import 'package:couple_app/services/chat_service.dart';
import 'package:couple_app/models/chat_message_model.dart';

void main() {
  late ChatService chatService;

  setUp(() {
    chatService = ChatService();
  });

  tearDown(() {
    chatService.dispose();
  });

  group('ChatService', () {
    group('getChatMessages', () {
      test('should return messages for given relationId', () async {
        final messages = await chatService.getChatMessages('relation_001');

        expect(messages, isNotEmpty);
        expect(messages.first.relationId, 'relation_001');
      });

      test('should return empty list for unknown relationId', () async {
        final messages = await chatService.getChatMessages('unknown_relation');

        expect(messages, isEmpty);
      });

      test('should return messages sorted by createdAt', () async {
        final messages = await chatService.getChatMessages('relation_001');

        for (var i = 1; i < messages.length; i++) {
          expect(
            messages[i].createdAt.isAfter(messages[i - 1].createdAt) ||
            messages[i].createdAt.isAtSameMomentAs(messages[i - 1].createdAt),
            true,
          );
        }
      });

      test('should filter messages before given time', () async {
        final beforeTime = DateTime(2026, 4, 27, 18, 25);
        final messages = await chatService.getChatMessages(
          'relation_001',
          beforeTime: beforeTime,
        );

        for (final message in messages) {
          expect(message.createdAt.isBefore(beforeTime), true);
        }
      });

      test('should limit messages to specified limit', () async {
        final messages = await chatService.getChatMessages(
          'relation_001',
          limit: 2,
        );

        expect(messages.length, lessThanOrEqualTo(2));
      });
    });

    group('sendTextMessage', () {
      test('should send text message successfully', () async {
        final message = await chatService.sendTextMessage(
          relationId: 'relation_001',
          senderId: 'user_001',
          receiverId: 'user_002',
          content: 'Test message',
        );

        expect(message.content, 'Test message');
        expect(message.messageType, ChatMessageType.text);
        expect(message.sendStatus, ChatSendStatus.sent);
        expect(message.senderId, 'user_001');
        expect(message.receiverId, 'user_002');
      });

      test('should return failed status when content contains "fail"', () async {
        final message = await chatService.sendTextMessage(
          relationId: 'relation_001',
          senderId: 'user_001',
          receiverId: 'user_002',
          content: 'This should fail',
        );

        expect(message.sendStatus, ChatSendStatus.failed);
      });

      test('should generate unique clientMsgId', () async {
        final message1 = await chatService.sendTextMessage(
          relationId: 'relation_001',
          senderId: 'user_001',
          receiverId: 'user_002',
          content: 'Message 1',
        );

        final message2 = await chatService.sendTextMessage(
          relationId: 'relation_001',
          senderId: 'user_001',
          receiverId: 'user_002',
          content: 'Message 2',
        );

        expect(message1.clientMsgId, isNot(equals(message2.clientMsgId)));
      });
    });

    group('sendImageMessage', () {
      test('should send image message successfully', () async {
        final message = await chatService.sendImageMessage(
          relationId: 'relation_001',
          senderId: 'user_001',
          receiverId: 'user_002',
          localPath: '/path/to/image.jpg',
          caption: 'Beautiful photo',
        );

        expect(message.messageType, ChatMessageType.image);
        expect(message.content, 'Beautiful photo');
        expect(message.sendStatus, ChatSendStatus.sent);
        expect(message.mediaUrl, isNotEmpty);
        expect(message.mediaThumbnailUrl, isNotEmpty);
      });

      test('should return failed status when localPath contains "fail"', () async {
        final message = await chatService.sendImageMessage(
          relationId: 'relation_001',
          senderId: 'user_001',
          receiverId: 'user_002',
          localPath: '/path/to/fail_image.jpg',
        );

        expect(message.sendStatus, ChatSendStatus.failed);
      });
    });

    group('markMessagesAsRead', () {
      test('should mark messages as read', () async {
        await chatService.sendTextMessage(
          relationId: 'relation_001',
          senderId: 'user_001',
          receiverId: 'user_002',
          content: 'Test message',
        );

        await chatService.markMessagesAsRead(
          relationId: 'relation_001',
          readerId: 'user_002',
        );

        // If no error is thrown, the test passes
      });
    });

    group('getUnreadCount', () {
      test('should return unread count', () async {
        final count = await chatService.getUnreadCount(
          relationId: 'relation_001',
          receiverId: 'user_002',
        );

        expect(count, greaterThanOrEqualTo(0));
      });
    });

    group('observeNewMessages', () {
      test('should return a stream', () {
        final stream = chatService.observeNewMessages('relation_001');

        expect(stream, isA<Stream<ChatMessage>>());
      });
    });
  });
}

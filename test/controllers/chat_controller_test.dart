import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:couple_app/services/chat_service.dart';
import 'package:couple_app/models/chat_message_model.dart';

class MockChatService extends Mock implements ChatService {}

class FakeChatMessage extends Fake implements ChatMessage {}

void main() {
  late MockChatService mockChatService;
  late ChatService realChatService;

  setUpAll(() {
    registerFallbackValue(FakeChatMessage());
  });

  setUp(() {
    mockChatService = MockChatService();
    realChatService = ChatService();
  });

  tearDown(() {
    realChatService.dispose();
  });

  group('ChatService Mock Tests', () {
    test('getChatMessages returns list of messages', () async {
      final messages = [
        ChatMessage(
          objectId: 'msg_1',
          clientMsgId: 'client_1',
          relationId: 'relation_001',
          senderId: 'user_001',
          receiverId: 'user_002',
          messageType: ChatMessageType.text,
          content: 'Hello',
          sendStatus: ChatSendStatus.sent,
          createdAt: DateTime.now(),
        ),
      ];

      when(() => mockChatService.getChatMessages(any()))
          .thenAnswer((_) async => messages);

      final result = await mockChatService.getChatMessages('relation_001');

      expect(result, messages);
      expect(result.length, 1);
      expect(result.first.content, 'Hello');
      verify(() => mockChatService.getChatMessages('relation_001')).called(1);
    });

    test('getChatMessages returns empty list for unknown relation', () async {
      when(() => mockChatService.getChatMessages(any()))
          .thenAnswer((_) async => []);

      final result = await mockChatService.getChatMessages('unknown');

      expect(result, isEmpty);
      verify(() => mockChatService.getChatMessages('unknown')).called(1);
    });

    test('sendTextMessage returns sent message', () async {
      final sentMessage = ChatMessage(
        objectId: 'msg_new',
        clientMsgId: 'client_new',
        relationId: 'relation_001',
        senderId: 'user_001',
        receiverId: 'user_002',
        messageType: ChatMessageType.text,
        content: 'Test message',
        sendStatus: ChatSendStatus.sent,
        createdAt: DateTime.now(),
      );

      when(() => mockChatService.sendTextMessage(
            relationId: any(named: 'relationId'),
            senderId: any(named: 'senderId'),
            receiverId: any(named: 'receiverId'),
            content: any(named: 'content'),
          )).thenAnswer((_) async => sentMessage);

      final result = await mockChatService.sendTextMessage(
        relationId: 'relation_001',
        senderId: 'user_001',
        receiverId: 'user_002',
        content: 'Test message',
      );

      expect(result.sendStatus, ChatSendStatus.sent);
      expect(result.content, 'Test message');
    });

    test('sendTextMessage returns failed message on error', () async {
      final failedMessage = ChatMessage(
        objectId: 'msg_failed',
        clientMsgId: 'client_failed',
        relationId: 'relation_001',
        senderId: 'user_001',
        receiverId: 'user_002',
        messageType: ChatMessageType.text,
        content: 'fail content',
        sendStatus: ChatSendStatus.failed,
        createdAt: DateTime.now(),
      );

      when(() => mockChatService.sendTextMessage(
            relationId: any(named: 'relationId'),
            senderId: any(named: 'senderId'),
            receiverId: any(named: 'receiverId'),
            content: any(named: 'content'),
          )).thenAnswer((_) async => failedMessage);

      final result = await mockChatService.sendTextMessage(
        relationId: 'relation_001',
        senderId: 'user_001',
        receiverId: 'user_002',
        content: 'fail content',
      );

      expect(result.sendStatus, ChatSendStatus.failed);
    });

    test('sendImageMessage returns sent image message', () async {
      final imageMessage = ChatMessage(
        objectId: 'img_new',
        clientMsgId: 'client_img',
        relationId: 'relation_001',
        senderId: 'user_001',
        receiverId: 'user_002',
        messageType: ChatMessageType.image,
        content: 'Photo caption',
        mediaUrl: 'https://example.com/photo.jpg',
        sendStatus: ChatSendStatus.sent,
        createdAt: DateTime.now(),
      );

      when(() => mockChatService.sendImageMessage(
            relationId: any(named: 'relationId'),
            senderId: any(named: 'senderId'),
            receiverId: any(named: 'receiverId'),
            localPath: any(named: 'localPath'),
            caption: any(named: 'caption'),
          )).thenAnswer((_) async => imageMessage);

      final result = await mockChatService.sendImageMessage(
        relationId: 'relation_001',
        senderId: 'user_001',
        receiverId: 'user_002',
        localPath: '/path/to/image.jpg',
        caption: 'Photo caption',
      );

      expect(result.messageType, ChatMessageType.image);
      expect(result.sendStatus, ChatSendStatus.sent);
      expect(result.mediaUrl, 'https://example.com/photo.jpg');
    });

    test('markMessagesAsRead completes without error', () async {
      when(() => mockChatService.markMessagesAsRead(
            relationId: any(named: 'relationId'),
            readerId: any(named: 'readerId'),
          )).thenAnswer((_) async {});

      await mockChatService.markMessagesAsRead(
        relationId: 'relation_001',
        readerId: 'user_002',
      );

      verify(() => mockChatService.markMessagesAsRead(
            relationId: 'relation_001',
            readerId: 'user_002',
          )).called(1);
    });

    test('getUnreadCount returns count', () async {
      when(() => mockChatService.getUnreadCount(
            relationId: any(named: 'relationId'),
            receiverId: any(named: 'receiverId'),
          )).thenAnswer((_) async => 5);

      final count = await mockChatService.getUnreadCount(
        relationId: 'relation_001',
        receiverId: 'user_002',
      );

      expect(count, 5);
    });

    test('observeNewMessages returns stream', () {
      when(() => mockChatService.observeNewMessages(any()))
          .thenAnswer((_) => Stream.value(ChatMessage(
                objectId: 'msg_1',
                clientMsgId: 'client_1',
                relationId: 'relation_001',
                senderId: 'user_001',
                receiverId: 'user_002',
                messageType: ChatMessageType.text,
                content: 'Stream message',
                sendStatus: ChatSendStatus.sent,
                createdAt: DateTime.now(),
              )));

      final stream = mockChatService.observeNewMessages('relation_001');

      expect(stream, isA<Stream<ChatMessage>>());
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:couple_app/models/chat_message_model.dart';

void main() {
  group('ChatMessage', () {
    final testJson = {
      'objectId': 'msg_123',
      'clientMsgId': 'client_123',
      'relationId': 'relation_001',
      'senderId': 'user_001',
      'receiverId': 'user_002',
      'messageType': 'text',
      'content': 'Hello, world!',
      'mediaUrl': null,
      'mediaThumbnailUrl': null,
      'mediaWidth': null,
      'mediaHeight': null,
      'locationAddress': null,
      'locationLat': null,
      'locationLng': null,
      'sendStatus': 'sent',
      'readAt': '2026-04-28T10:00:00.000Z',
      'createdAt': '2026-04-28T09:00:00.000Z',
    };

    final testDateTime = DateTime.parse('2026-04-28T10:00:00.000Z');

    test('fromJson should correctly parse valid JSON', () {
      final message = ChatMessage.fromJson(testJson);

      expect(message.objectId, 'msg_123');
      expect(message.clientMsgId, 'client_123');
      expect(message.relationId, 'relation_001');
      expect(message.senderId, 'user_001');
      expect(message.receiverId, 'user_002');
      expect(message.messageType, ChatMessageType.text);
      expect(message.content, 'Hello, world!');
      expect(message.sendStatus, ChatSendStatus.sent);
      expect(message.createdAt.year, 2026);
    });

    test('fromJson should handle missing fields with defaults', () {
      final minimalJson = {
        'relationId': 'relation_001',
        'senderId': 'user_001',
        'receiverId': 'user_002',
      };

      final message = ChatMessage.fromJson(minimalJson);

      expect(message.objectId, '');
      expect(message.content, null);
      expect(message.messageType, ChatMessageType.text);
      expect(message.sendStatus, ChatSendStatus.sending);
    });

    test('fromJson should handle id field as fallback for objectId', () {
      final jsonWithId = {
        'id': 'msg_456',
        'relationId': 'relation_001',
        'senderId': 'user_001',
        'receiverId': 'user_002',
      };

      final message = ChatMessage.fromJson(jsonWithId);

      expect(message.objectId, 'msg_456');
    });

    test('fromJson should parse integer timestamps correctly', () {
      final jsonWithIntTimestamp = {
        ...testJson,
        'createdAt': 1714291200000, // milliseconds since epoch
        'readAt': 1714291200000,
      };

      final message = ChatMessage.fromJson(jsonWithIntTimestamp);

      expect(message.createdAt.millisecondsSinceEpoch, 1714291200000);
      expect(message.readAt?.millisecondsSinceEpoch, 1714291200000);
    });

    test('toJson should correctly serialize message', () {
      final message = ChatMessage(
        objectId: 'msg_123',
        clientMsgId: 'client_123',
        relationId: 'relation_001',
        senderId: 'user_001',
        receiverId: 'user_002',
        messageType: ChatMessageType.text,
        content: 'Hello, world!',
        sendStatus: ChatSendStatus.sent,
        createdAt: DateTime.parse('2026-04-28T09:00:00.000Z'),
        readAt: DateTime.parse('2026-04-28T10:00:00.000Z'),
      );

      final json = message.toJson();

      expect(json['objectId'], 'msg_123');
      expect(json['clientMsgId'], 'client_123');
      expect(json['messageType'], 'text');
      expect(json['content'], 'Hello, world!');
      expect(json['sendStatus'], 'sent');
    });

    test('copyWith should create a new instance with updated fields', () {
      final original = ChatMessage(
        objectId: 'msg_123',
        clientMsgId: 'client_123',
        relationId: 'relation_001',
        senderId: 'user_001',
        receiverId: 'user_002',
        messageType: ChatMessageType.text,
        content: 'Original content',
        sendStatus: ChatSendStatus.sending,
        createdAt: DateTime.now(),
      );

      final updated = original.copyWith(
        content: 'Updated content',
        sendStatus: ChatSendStatus.sent,
      );

      expect(updated.objectId, original.objectId);
      expect(updated.content, 'Updated content');
      expect(updated.sendStatus, ChatSendStatus.sent);
      expect(original.content, 'Original content');
      expect(original.sendStatus, ChatSendStatus.sending);
    });

    test('copyWith should preserve unchanged fields', () {
      final original = ChatMessage(
        objectId: 'msg_123',
        clientMsgId: 'client_123',
        relationId: 'relation_001',
        senderId: 'user_001',
        receiverId: 'user_002',
        messageType: ChatMessageType.text,
        content: 'Content',
        sendStatus: ChatSendStatus.sent,
        createdAt: DateTime.parse('2026-04-28T09:00:00.000Z'),
      );

      final updated = original.copyWith(sendStatus: ChatSendStatus.read);

      expect(updated.objectId, original.objectId);
      expect(updated.relationId, original.relationId);
      expect(updated.senderId, original.senderId);
      expect(updated.receiverId, original.receiverId);
      expect(updated.messageType, original.messageType);
      expect(updated.content, original.content);
    });

    test('ChatMessageType.fromString should return correct enum values', () {
      expect(ChatMessageType.fromString('text'), ChatMessageType.text);
      expect(ChatMessageType.fromString('image'), ChatMessageType.image);
      expect(ChatMessageType.fromString('emoji'), ChatMessageType.emoji);
      expect(ChatMessageType.fromString('system'), ChatMessageType.system);
      expect(ChatMessageType.fromString('unknown'), ChatMessageType.text);
      expect(ChatMessageType.fromString(null), ChatMessageType.text);
    });

    test('ChatSendStatus.fromString should return correct enum values', () {
      expect(ChatSendStatus.fromString('sending'), ChatSendStatus.sending);
      expect(ChatSendStatus.fromString('sent'), ChatSendStatus.sent);
      expect(ChatSendStatus.fromString('failed'), ChatSendStatus.failed);
      expect(ChatSendStatus.fromString('read'), ChatSendStatus.read);
      expect(ChatSendStatus.fromString('unknown'), ChatSendStatus.sending);
      expect(ChatSendStatus.fromString(null), ChatSendStatus.sending);
    });

    test('props should include all fields for equality comparison', () {
      final message1 = ChatMessage(
        objectId: 'msg_123',
        clientMsgId: 'client_123',
        relationId: 'relation_001',
        senderId: 'user_001',
        receiverId: 'user_002',
        messageType: ChatMessageType.text,
        content: 'Content',
        sendStatus: ChatSendStatus.sent,
        createdAt: DateTime.now(),
      );

      final message2 = ChatMessage(
        objectId: 'msg_123',
        clientMsgId: 'client_123',
        relationId: 'relation_001',
        senderId: 'user_001',
        receiverId: 'user_002',
        messageType: ChatMessageType.text,
        content: 'Content',
        sendStatus: ChatSendStatus.sent,
        createdAt: DateTime.now(),
      );

      // Different instances but same props
      expect(message1.props.length, greaterThan(0));
      expect(message1.props, message2.props);
    });
  });
}

import 'package:couple_app/models/chat_message_model.dart';
import 'package:couple_app/models/mood_record_model.dart';
import 'package:couple_app/models/diary_entry_model.dart';
import 'package:couple_app/models/wish_item_model.dart';
import 'package:couple_app/models/album_photo_model.dart';
import 'package:couple_app/models/anniversary_model.dart';
import 'package:couple_app/models/user_model.dart';
import 'package:couple_app/models/couple_model.dart';

/// Mock data generators for testing
class MockData {
  // ==================== Chat Message ====================

  static ChatMessage createChatMessage({
    String? objectId,
    String? clientMsgId,
    String? relationId,
    String? senderId,
    String? receiverId,
    ChatMessageType? messageType,
    String? content,
    ChatSendStatus? sendStatus,
    DateTime? createdAt,
  }) {
    return ChatMessage(
      objectId: objectId ?? 'msg_${DateTime.now().microsecondsSinceEpoch}',
      clientMsgId: clientMsgId ?? 'client_${DateTime.now().microsecondsSinceEpoch}',
      relationId: relationId ?? 'relation_001',
      senderId: senderId ?? 'user_001',
      receiverId: receiverId ?? 'user_002',
      messageType: messageType ?? ChatMessageType.text,
      content: content ?? 'Test message',
      sendStatus: sendStatus ?? ChatSendStatus.sent,
      createdAt: createdAt ?? DateTime.now(),
    );
  }

  static List<ChatMessage> createChatMessageList({
    int count = 5,
    String relationId = 'relation_001',
  }) {
    return List.generate(
      count,
      (index) => createChatMessage(
        objectId: 'msg_$index',
        clientMsgId: 'client_$index',
        relationId: relationId,
        createdAt: DateTime.now().subtract(Duration(minutes: count - index)),
      ),
    );
  }

  // ==================== Mood Record ====================

  static MoodRecord createMoodRecord({
    String? objectId,
    String? relationId,
    String? userId,
    MoodType? moodType,
    int? moodScore,
    String? content,
    bool? visibleToPartner,
    DateTime? recordDate,
  }) {
    return MoodRecord(
      objectId: objectId ?? 'mood_${DateTime.now().microsecondsSinceEpoch}',
      relationId: relationId ?? 'relation_001',
      userId: userId ?? 'user_001',
      moodType: moodType ?? MoodType.happy,
      moodScore: moodScore ?? 5,
      content: content ?? '测试心情',
      visibleToPartner: visibleToPartner ?? true,
      recordDate: recordDate ?? DateTime.now(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  static List<MoodRecord> createMoodRecordList({
    int count = 5,
    String relationId = 'relation_001',
  }) {
    return List.generate(
      count,
      (index) => createMoodRecord(
        objectId: 'mood_$index',
        relationId: relationId,
        recordDate: DateTime.now().subtract(Duration(days: index)),
      ),
    );
  }

  // ==================== Diary Entry ====================

  static DiaryEntry createDiaryEntry({
    String? objectId,
    String? relationId,
    String? authorId,
    String? title,
    String? content,
    DiaryMoodType? moodType,
    WeatherType? weather,
    bool? isPrivate,
    DateTime? recordDate,
  }) {
    return DiaryEntry(
      objectId: objectId ?? 'diary_${DateTime.now().microsecondsSinceEpoch}',
      relationId: relationId ?? 'relation_001',
      authorId: authorId ?? 'user_001',
      title: title ?? '测试日记',
      content: content ?? '这是测试日记内容',
      moodType: moodType ?? DiaryMoodType.happy,
      weather: weather ?? WeatherType.sunny,
      isPrivate: isPrivate ?? false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      recordDate: recordDate ?? DateTime.now(),
    );
  }

  static List<DiaryEntry> createDiaryEntryList({
    int count = 5,
    String relationId = 'relation_001',
  }) {
    return List.generate(
      count,
      (index) => createDiaryEntry(
        objectId: 'diary_$index',
        relationId: relationId,
        recordDate: DateTime.now().subtract(Duration(days: index)),
      ),
    );
  }

  // ==================== Wish Item ====================

  static WishItem createWishItem({
    String? objectId,
    String? relationId,
    String? title,
    String? description,
    WishCategory? category,
    WishPriority? priority,
    WishStatus? status,
    DateTime? targetDate,
  }) {
    return WishItem(
      objectId: objectId ?? 'wish_${DateTime.now().microsecondsSinceEpoch}',
      relationId: relationId ?? 'relation_001',
      title: title ?? '测试愿望',
      description: description ?? '这是测试愿望描述',
      category: category ?? WishCategory.other,
      priority: priority ?? WishPriority.medium,
      status: status ?? WishStatus.pending,
      targetDate: targetDate,
      createdBy: 'user_001',
      createdAt: DateTime.now(),
    );
  }

  static List<WishItem> createWishItemList({
    int count = 5,
    String relationId = 'relation_001',
    WishStatus? status,
  }) {
    return List.generate(
      count,
      (index) => createWishItem(
        objectId: 'wish_$index',
        relationId: relationId,
        status: status ?? (index % 3 == 0 ? WishStatus.fulfilled : WishStatus.pending),
      ),
    );
  }

  // ==================== Album Photo ====================

  static AlbumPhoto createAlbumPhoto({
    String? objectId,
    String? relationId,
    String? uploaderId,
    String? caption,
    AlbumVisibility? visibility,
  }) {
    return AlbumPhoto(
      objectId: objectId ?? 'photo_${DateTime.now().microsecondsSinceEpoch}',
      relationId: relationId ?? 'relation_001',
      uploaderId: uploaderId ?? 'user_001',
      photoUrl: 'https://example.com/photo.jpg',
      thumbnailUrl: 'https://example.com/thumb.jpg',
      caption: caption ?? '测试照片描述',
      visibility: visibility ?? AlbumVisibility.both,
      createdAt: DateTime.now(),
    );
  }

  static List<AlbumPhoto> createAlbumPhotoList({
    int count = 5,
    String relationId = 'relation_001',
  }) {
    return List.generate(
      count,
      (index) => createAlbumPhoto(
        objectId: 'photo_$index',
        relationId: relationId,
      ),
    );
  }

  // ==================== Anniversary ====================

  static Anniversary createAnniversary({
    String? objectId,
    String? relationId,
    String? title,
    DateTime? date,
    AnniversaryType? type,
    AnniversaryRepeatType? repeatType,
  }) {
    return Anniversary(
      objectId: objectId ?? 'anniv_${DateTime.now().microsecondsSinceEpoch}',
      relationId: relationId ?? 'relation_001',
      title: title ?? '测试纪念日',
      date: date ?? DateTime.now().add(const Duration(days: 30)),
      type: type ?? AnniversaryType.love,
      repeatType: repeatType ?? AnniversaryRepeatType.none,
      reminderEnabled: true,
      createdBy: 'user_001',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  static List<Anniversary> createAnniversaryList({
    int count = 5,
    String relationId = 'relation_001',
  }) {
    return List.generate(
      count,
      (index) => createAnniversary(
        objectId: 'anniv_$index',
        relationId: relationId,
        date: DateTime.now().add(Duration(days: index * 30)),
      ),
    );
  }

  // ==================== User Model ====================

  static UserModel createUserModel({
    String? id,
    String? nickname,
    String? avatar,
  }) {
    return UserModel(
      id: id ?? 'user_001',
      nickname: nickname ?? '测试用户',
      avatar: avatar ?? 'https://example.com/avatar.jpg',
      gender: 'female',
      birthday: DateTime(2000, 1, 1),
      signature: '这是一个测试签名',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  static CoupleModel createCoupleModel({
    String? id,
    UserModel? userA,
    UserModel? userB,
  }) {
    return CoupleModel(
      id: id ?? 'relation_001',
      relationCode: 'CP123456',
      userA: userA ?? createUserModel(id: 'user_001', nickname: '用户A'),
      userB: userB ?? createUserModel(id: 'user_002', nickname: '用户B'),
      anniversaryDate: DateTime(2025, 1, 1),
      status: CoupleStatus.active,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}

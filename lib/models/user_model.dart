import 'package:equatable/equatable.dart';

/// 用户模型
class UserModel extends Equatable {
  /// 用户 ID
  final String id;

  /// 昵称
  final String nickname;

  /// 头像 URL
  final String? avatar;

  /// 性别：male / female / other
  final String? gender;

  /// 生日
  final DateTime? birthday;

  /// 个性签名
  final String? signature;

  /// 手机号
  final String? phone;

  /// 邮箱
  final String? email;

  /// 设备 ID
  final String? deviceId;

  /// 推送 Registration ID
  final String? jpushRegistrationId;

  /// 是否授权位置
  final bool locationPermission;

  /// 是否开启通知
  final bool notificationEnabled;

  /// 最近活跃时间
  final DateTime? lastActiveAt;

  /// 创建时间
  final DateTime createdAt;

  /// 更新时间
  final DateTime updatedAt;

  const UserModel({
    required this.id,
    required this.nickname,
    this.avatar,
    this.gender,
    this.birthday,
    this.signature,
    this.phone,
    this.email,
    this.deviceId,
    this.jpushRegistrationId,
    this.locationPermission = false,
    this.notificationEnabled = true,
    this.lastActiveAt,
    required this.createdAt,
    required this.updatedAt,
  });

  /// 从 JSON 创建
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? json['objectId'] ?? '',
      nickname: json['nickname'] ?? '未设置昵称',
      avatar: json['avatar'],
      gender: json['gender'],
      birthday: json['birthday'] != null ? DateTime.tryParse(json['birthday']) : null,
      signature: json['signature'],
      phone: json['phone'],
      email: json['email'],
      deviceId: json['deviceId'],
      jpushRegistrationId: json['jpushRegistrationId'],
      locationPermission: json['locationPermission'] ?? false,
      notificationEnabled: json['notificationEnabled'] ?? true,
      lastActiveAt: json['lastActiveAt'] != null
          ? DateTime.tryParse(json['lastActiveAt'])
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
    );
  }

  /// 转为 JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nickname': nickname,
      'avatar': avatar,
      'gender': gender,
      'birthday': birthday?.toIso8601String(),
      'signature': signature,
      'phone': phone,
      'email': email,
      'deviceId': deviceId,
      'jpushRegistrationId': jpushRegistrationId,
      'locationPermission': locationPermission,
      'notificationEnabled': notificationEnabled,
      'lastActiveAt': lastActiveAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// 复制并修改
  UserModel copyWith({
    String? id,
    String? nickname,
    String? avatar,
    String? gender,
    DateTime? birthday,
    String? signature,
    String? phone,
    String? email,
    String? deviceId,
    String? jpushRegistrationId,
    bool? locationPermission,
    bool? notificationEnabled,
    DateTime? lastActiveAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      nickname: nickname ?? this.nickname,
      avatar: avatar ?? this.avatar,
      gender: gender ?? this.gender,
      birthday: birthday ?? this.birthday,
      signature: signature ?? this.signature,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      deviceId: deviceId ?? this.deviceId,
      jpushRegistrationId: jpushRegistrationId ?? this.jpushRegistrationId,
      locationPermission: locationPermission ?? this.locationPermission,
      notificationEnabled: notificationEnabled ?? this.notificationEnabled,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        nickname,
        avatar,
        gender,
        birthday,
        signature,
        phone,
        email,
        deviceId,
        jpushRegistrationId,
        locationPermission,
        notificationEnabled,
        lastActiveAt,
        createdAt,
        updatedAt,
      ];
}

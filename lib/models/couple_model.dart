import 'package:equatable/equatable.dart';
import 'user_model.dart';

/// 情侣关系状态
enum CoupleStatus { pending, active, unbound }

/// 情侣关系模型
class CoupleModel extends Equatable {
  /// 关系 ID
  final String id;

  /// 邀请码
  final String relationCode;

  /// 用户 A
  final UserModel? userA;

  /// 用户 B
  final UserModel? userB;

  /// 恋爱纪念日
  final DateTime? anniversaryDate;

  /// 状态：pending / active / unbound
  final CoupleStatus status;

  /// 关系主页背景图
  final String? backgroundImage;

  /// 主题配置
  final Map<String, dynamic>? themeConfig;

  /// CP 昵称
  final String? coupleName;

  /// 最近互动时间
  final DateTime? lastInteractionAt;

  /// 发起人
  final String? createdBy;

  /// 创建时间
  final DateTime createdAt;

  /// 更新时间
  final DateTime updatedAt;

  const CoupleModel({
    required this.id,
    required this.relationCode,
    this.userA,
    this.userB,
    this.anniversaryDate,
    required this.status,
    this.backgroundImage,
    this.themeConfig,
    this.coupleName,
    this.lastInteractionAt,
    this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  /// 从 JSON 创建
  factory CoupleModel.fromJson(Map<String, dynamic> json) {
    return CoupleModel(
      id: json['id'] ?? json['objectId'] ?? '',
      relationCode: json['relationCode'] ?? '',
      userA: json['userA'] != null ? UserModel.fromJson(json['userA']) : null,
      userB: json['userB'] != null ? UserModel.fromJson(json['userB']) : null,
      anniversaryDate: (json['anniversaryDate'] is String)
          ? DateTime.tryParse(json['anniversaryDate'])
          : null,
      status: _parseStatus(json['status']),
      backgroundImage: json['backgroundImage'],
      themeConfig: json['themeConfig'],
      coupleName: json['coupleName'],
      lastInteractionAt: (json['lastInteractionAt'] is String)
          ? DateTime.tryParse(json['lastInteractionAt'])
          : null,
      createdBy: json['createdBy'],
      createdAt: (json['createdAt'] is String)
          ? DateTime.tryParse(json['createdAt']) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: (json['updatedAt'] is String)
          ? DateTime.tryParse(json['updatedAt']) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  /// 解析状态
  static CoupleStatus _parseStatus(String? status) {
    switch (status) {
      case 'pending':
        return CoupleStatus.pending;
      case 'active':
        return CoupleStatus.active;
      case 'unbound':
        return CoupleStatus.unbound;
      default:
        return CoupleStatus.pending;
    }
  }

  /// 状态转字符串
  String statusToString() {
    switch (status) {
      case CoupleStatus.pending:
        return 'pending';
      case CoupleStatus.active:
        return 'active';
      case CoupleStatus.unbound:
        return 'unbound';
    }
  }

  /// 转为 JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'relationCode': relationCode,
      'userA': userA?.toJson(),
      'userB': userB?.toJson(),
      'anniversaryDate': anniversaryDate?.toIso8601String(),
      'status': statusToString(),
      'backgroundImage': backgroundImage,
      'themeConfig': themeConfig,
      'coupleName': coupleName,
      'lastInteractionAt': lastInteractionAt?.toIso8601String(),
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// 复制并修改
  CoupleModel copyWith({
    String? id,
    String? relationCode,
    UserModel? userA,
    UserModel? userB,
    DateTime? anniversaryDate,
    CoupleStatus? status,
    String? backgroundImage,
    Map<String, dynamic>? themeConfig,
    String? coupleName,
    DateTime? lastInteractionAt,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CoupleModel(
      id: id ?? this.id,
      relationCode: relationCode ?? this.relationCode,
      userA: userA ?? this.userA,
      userB: userB ?? this.userB,
      anniversaryDate: anniversaryDate ?? this.anniversaryDate,
      status: status ?? this.status,
      backgroundImage: backgroundImage ?? this.backgroundImage,
      themeConfig: themeConfig ?? this.themeConfig,
      coupleName: coupleName ?? this.coupleName,
      lastInteractionAt: lastInteractionAt ?? this.lastInteractionAt,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// 计算在一起天数
  int get daysTogether {
    if (anniversaryDate == null) return 0;
    return DateTime.now().difference(anniversaryDate!).inDays;
  }

  @override
  List<Object?> get props => [
        id,
        relationCode,
        userA,
        userB,
        anniversaryDate,
        status,
        backgroundImage,
        themeConfig,
        coupleName,
        lastInteractionAt,
        createdBy,
        createdAt,
        updatedAt,
      ];
}

import 'package:equatable/equatable.dart';

/// 愿望分类
enum WishCategory {
  travel,
  food,
  gift,
  other;

  static WishCategory fromString(String? value) {
    return WishCategory.values.firstWhere(
      (item) => item.name == value,
      orElse: () => WishCategory.other,
    );
  }
}

/// 优先级
enum WishPriority {
  high,
  medium,
  low;

  static WishPriority fromString(String? value) {
    return WishPriority.values.firstWhere(
      (item) => item.name == value,
      orElse: () => WishPriority.medium,
    );
  }
}

/// 状态
enum WishStatus {
  pending,
  fulfilled,
  abandoned;

  static WishStatus fromString(String? value) {
    return WishStatus.values.firstWhere(
      (item) => item.name == value,
      orElse: () => WishStatus.pending,
    );
  }
}

/// 愿望项
class WishItem extends Equatable {
  final String objectId;
  final String relationId;
  final String title;
  final String? description;
  final WishCategory category;
  final WishPriority priority;
  final WishStatus status;
  final DateTime? targetDate;
  final DateTime? fulfilledAt;
  final String createdBy;
  final DateTime createdAt;

  const WishItem({
    required this.objectId,
    required this.relationId,
    required this.title,
    this.description,
    required this.category,
    required this.priority,
    required this.status,
    this.targetDate,
    this.fulfilledAt,
    required this.createdBy,
    required this.createdAt,
  });

  factory WishItem.fromJson(Map<String, dynamic> json) {
    return WishItem(
      objectId: (json['objectId'] ?? json['id'] ?? '').toString(),
      relationId: (json['relationId'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      description: json['description']?.toString(),
      category: WishCategory.fromString(json['category']?.toString()),
      priority: WishPriority.fromString(json['priority']?.toString()),
      status: WishStatus.fromString(json['status']?.toString()),
      targetDate: _parseDateTime(json['targetDate']),
      fulfilledAt: _parseDateTime(json['fulfilledAt']),
      createdBy: (json['createdBy'] ?? '').toString(),
      createdAt: _parseDateTime(json['createdAt']) ?? DateTime.now(),
    );
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    if (value is String && value.isNotEmpty) return DateTime.tryParse(value);
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'objectId': objectId,
      'relationId': relationId,
      'title': title,
      'description': description,
      'category': category.name,
      'priority': priority.name,
      'status': status.name,
      'targetDate': targetDate?.toIso8601String(),
      'fulfilledAt': fulfilledAt?.toIso8601String(),
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  WishItem copyWith({
    String? objectId,
    String? relationId,
    String? title,
    String? description,
    WishCategory? category,
    WishPriority? priority,
    WishStatus? status,
    DateTime? targetDate,
    DateTime? fulfilledAt,
    String? createdBy,
    DateTime? createdAt,
    bool clearTargetDate = false,
    bool clearFulfilledAt = false,
  }) {
    return WishItem(
      objectId: objectId ?? this.objectId,
      relationId: relationId ?? this.relationId,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      targetDate: clearTargetDate ? null : (targetDate ?? this.targetDate),
      fulfilledAt: clearFulfilledAt ? null : (fulfilledAt ?? this.fulfilledAt),
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        objectId,
        relationId,
        title,
        description,
        category,
        priority,
        status,
        targetDate,
        fulfilledAt,
        createdBy,
        createdAt,
      ];
}

extension WishCategoryX on WishCategory {
  String get label {
    switch (this) {
      case WishCategory.travel:
        return '旅行';
      case WishCategory.food:
        return '美食';
      case WishCategory.gift:
        return '礼物';
      case WishCategory.other:
        return '其他';
    }
  }

  String get icon {
    switch (this) {
      case WishCategory.travel:
        return '✈️';
      case WishCategory.food:
        return '🍜';
      case WishCategory.gift:
        return '🎁';
      case WishCategory.other:
        return '✨';
    }
  }
}

extension WishPriorityX on WishPriority {
  String get label {
    switch (this) {
      case WishPriority.high:
        return '高';
      case WishPriority.medium:
        return '中';
      case WishPriority.low:
        return '低';
    }
  }

  int get colorValue {
    switch (this) {
      case WishPriority.high:
        return 0xFFE53935;
      case WishPriority.medium:
        return 0xFFFFA726;
      case WishPriority.low:
        return 0xFF66BB6A;
    }
  }
}

extension WishStatusX on WishStatus {
  String get label {
    switch (this) {
      case WishStatus.pending:
        return '进行中';
      case WishStatus.fulfilled:
        return '已实现';
      case WishStatus.abandoned:
        return '已放弃';
    }
  }

  int get colorValue {
    switch (this) {
      case WishStatus.pending:
        return 0xFF42A5F5;
      case WishStatus.fulfilled:
        return 0xFF66BB6A;
      case WishStatus.abandoned:
        return 0xFF9E9E9E;
    }
  }
}

extension WishItemX on WishItem {
  String get categoryIcon => category.icon;
  String get priorityLabel => priority.label;
  String get statusLabel => status.label;
  int get priorityColorValue => priority.colorValue;
  int get statusColorValue => status.colorValue;

  int? get daysRemaining {
    if (targetDate == null) return null;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(targetDate!.year, targetDate!.month, targetDate!.day);
    return target.difference(today).inDays;
  }

  bool get isOverdue {
    final days = daysRemaining;
    return days != null && days < 0 && status == WishStatus.pending;
  }
}

import 'package:equatable/equatable.dart';

/// 位置共享记录
class LocationShare extends Equatable {
  final String objectId;
  final String relationId;
  final String userId;
  final double latitude;
  final double longitude;
  final double? accuracy;
  final double? altitude;
  final double? speed;
  final double? heading;
  final DateTime timestamp;
  final DateTime? expiresAt;
  final bool isActive;

  const LocationShare({
    required this.objectId,
    required this.relationId,
    required this.userId,
    required this.latitude,
    required this.longitude,
    this.accuracy,
    this.altitude,
    this.speed,
    this.heading,
    required this.timestamp,
    this.expiresAt,
    required this.isActive,
  });

  factory LocationShare.fromJson(Map<String, dynamic> json) {
    return LocationShare(
      objectId: _parseString(json['objectId'] ?? json['id']),
      relationId: _parseString(json['relationId']),
      userId: _parseString(json['userId']),
      latitude: _parseDouble(json['latitude']) ?? 0.0,
      longitude: _parseDouble(json['longitude']) ?? 0.0,
      accuracy: _parseDouble(json['accuracy']),
      altitude: _parseDouble(json['altitude']),
      speed: _parseDouble(json['speed']),
      heading: _parseDouble(json['heading']),
      timestamp: _parseDateTime(json['timestamp']) ?? DateTime.now(),
      expiresAt: _parseDateTime(json['expiresAt']),
      isActive: json['isActive'] == true || json['isActive'] == 'true',
    );
  }

  static String _parseString(dynamic value) {
    if (value == null) return '';
    if (value is String) return value;
    return value.toString();
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'objectId': objectId,
      'relationId': relationId,
      'userId': userId,
      'latitude': latitude,
      'longitude': longitude,
      'accuracy': accuracy,
      'altitude': altitude,
      'speed': speed,
      'heading': heading,
      'timestamp': timestamp.toIso8601String(),
      'expiresAt': expiresAt?.toIso8601String(),
      'isActive': isActive,
    };
  }

  LocationShare copyWith({
    String? objectId,
    String? relationId,
    String? userId,
    double? latitude,
    double? longitude,
    double? accuracy,
    double? altitude,
    double? speed,
    double? heading,
    DateTime? timestamp,
    DateTime? expiresAt,
    bool? isActive,
  }) {
    return LocationShare(
      objectId: objectId ?? this.objectId,
      relationId: relationId ?? this.relationId,
      userId: userId ?? this.userId,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      accuracy: accuracy ?? this.accuracy,
      altitude: altitude ?? this.altitude,
      speed: speed ?? this.speed,
      heading: heading ?? this.heading,
      timestamp: timestamp ?? this.timestamp,
      expiresAt: expiresAt ?? this.expiresAt,
      isActive: isActive ?? this.isActive,
    );
  }

  /// 计算与另一个位置的距离（米）
  double distanceTo(LocationShare other) {
    return _haversineDistance(
      latitude,
      longitude,
      other.latitude,
      other.longitude,
    );
  }

  /// Haversine 公式计算两点间距离
  static double _haversineDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double earthRadius = 6371000; // 地球半径（米）
    final double dLat = _toRadians(lat2 - lat1);
    final double dLon = _toRadians(lon2 - lon1);
    final double a = _sin(dLat / 2) * _sin(dLat / 2) +
        _cos(_toRadians(lat1)) *
            _cos(_toRadians(lat2)) *
            _sin(dLon / 2) *
            _sin(dLon / 2);
    final double c = 2 * _atan2(_sqrt(a), _sqrt(1 - a));
    return earthRadius * c;
  }

  static double _toRadians(double degree) => degree * 3.141592653589793 / 180;
  static double _sin(double x) => _taylorSin(x);
  static double _cos(double x) => _taylorCos(x);
  static double _sqrt(double x) => _newtonSqrt(x);
  static double _atan2(double y, double x) => _approximateAtan2(y, x);

  static double _taylorSin(double x) {
    x = x % (2 * 3.141592653589793);
    double result = x;
    double term = x;
    for (int i = 1; i <= 10; i++) {
      term *= -x * x / ((2 * i) * (2 * i + 1));
      result += term;
    }
    return result;
  }

  static double _taylorCos(double x) {
    x = x % (2 * 3.141592653589793);
    double result = 1;
    double term = 1;
    for (int i = 1; i <= 10; i++) {
      term *= -x * x / ((2 * i - 1) * (2 * i));
      result += term;
    }
    return result;
  }

  static double _newtonSqrt(double x) {
    if (x <= 0) return 0;
    double guess = x / 2;
    for (int i = 0; i < 20; i++) {
      guess = (guess + x / guess) / 2;
    }
    return guess;
  }

  static double _approximateAtan2(double y, double x) {
    if (x == 0) {
      if (y > 0) return 3.141592653589793 / 2;
      if (y < 0) return -3.141592653589793 / 2;
      return 0;
    }
    double atan = _approximateAtan(y / x);
    if (x < 0) {
      if (y >= 0) return atan + 3.141592653589793;
      return atan - 3.141592653589793;
    }
    return atan;
  }

  static double _approximateAtan(double x) {
    if (x > 1) return 3.141592653589793 / 2 - _approximateAtan(1 / x);
    if (x < -1) return -3.141592653589793 / 2 - _approximateAtan(1 / x);
    double result = x;
    double term = x;
    for (int i = 1; i <= 15; i++) {
      term *= -x * x;
      result += term / (2 * i + 1);
    }
    return result;
  }

  @override
  List<Object?> get props => [
        objectId,
        relationId,
        userId,
        latitude,
        longitude,
        accuracy,
        altitude,
        speed,
        heading,
        timestamp,
        expiresAt,
        isActive,
      ];
}

extension LocationShareX on LocationShare {
  /// 格式化距离
  String get formattedDistance {
    const double metersInKm = 1000;
    if (latitude == 0 && longitude == 0) return '未知';
    return '${(accuracy ?? 0).toStringAsFixed(0)}m';
  }

  /// 是否过期
  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  /// 速度格式化（km/h）
  String? get formattedSpeed {
    if (speed == null) return null;
    return '${(speed! * 3.6).toStringAsFixed(1)} km/h';
  }

  /// 方向描述
  String? get headingDescription {
    if (heading == null) return null;
    final h = heading!;
    if (h >= 337.5 || h < 22.5) return '北';
    if (h >= 22.5 && h < 67.5) return '东北';
    if (h >= 67.5 && h < 112.5) return '东';
    if (h >= 112.5 && h < 157.5) return '东南';
    if (h >= 157.5 && h < 202.5) return '南';
    if (h >= 202.5 && h < 247.5) return '西南';
    if (h >= 247.5 && h < 292.5) return '西';
    if (h >= 292.5 && h < 337.5) return '西北';
    return null;
  }
}

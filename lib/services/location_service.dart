import 'dart:async';
import 'dart:math';

import '../models/location_share_model.dart';

/// 位置服务（Mock 实现）
class LocationService {
  final List<LocationShare> _locationHistory = [];
  final _partnerLocationController = StreamController<LocationShare>.broadcast();
  Timer? _mockLocationTimer;
  bool _isSharing = false;

  // Mock 搭档位置（北京朝阳区附近）
  double _mockPartnerLat = 39.9042 + (Random().nextDouble() - 0.5) * 0.01;
  double _mockPartnerLng = 116.4074 + (Random().nextDouble() - 0.5) * 0.01;

  /// 当前用户自己的位置
  LocationShare? _myCurrentLocation;

  /// 搭档位置流
  Stream<LocationShare> get partnerLocationStream =>
      _partnerLocationController.stream;

  /// 是否正在共享
  bool get isSharing => _isSharing;

  /// 开始位置共享
  Future<LocationShare> startLocationSharing({
    required String relationId,
    required String userId,
    required double latitude,
    required double longitude,
    double? accuracy,
    double? altitude,
    double? speed,
    double? heading,
    Duration expiresIn = const Duration(hours: 24),
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));

    _myCurrentLocation = LocationShare(
      objectId: 'loc_${DateTime.now().millisecondsSinceEpoch}',
      relationId: relationId,
      userId: userId,
      latitude: latitude,
      longitude: longitude,
      accuracy: accuracy,
      altitude: altitude,
      speed: speed,
      heading: heading,
      timestamp: DateTime.now(),
      expiresAt: DateTime.now().add(expiresIn),
      isActive: true,
    );

    _locationHistory.add(_myCurrentLocation!);
    _isSharing = true;

    // 启动 Mock 搭档位置更新
    _startMockPartnerUpdates();

    return _myCurrentLocation!;
  }

  /// 停止位置共享
  Future<void> stopLocationSharing({
    required String relationId,
    required String userId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));

    _isSharing = false;
    _mockLocationTimer?.cancel();
    _mockLocationTimer = null;

    if (_myCurrentLocation != null) {
      _myCurrentLocation = _myCurrentLocation!.copyWith(isActive: false);
    }
  }

  /// 获取搭档当前位置
  Future<LocationShare?> getPartnerLocation({
    required String relationId,
    required String partnerId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 150));

    if (!_isSharing) return null;

    return LocationShare(
      objectId: 'partner_loc_${DateTime.now().millisecondsSinceEpoch}',
      relationId: relationId,
      userId: partnerId,
      latitude: _mockPartnerLat,
      longitude: _mockPartnerLng,
      accuracy: 10.0 + Random().nextDouble() * 20,
      altitude: 50.0 + Random().nextDouble() * 10,
      speed: 0.5 + Random().nextDouble() * 2,
      heading: Random().nextDouble() * 360,
      timestamp: DateTime.now(),
      expiresAt: DateTime.now().add(const Duration(minutes: 5)),
      isActive: true,
    );
  }

  /// 观察搭档位置（Stream）
  Stream<LocationShare> observePartnerLocation({
    required String relationId,
    required String partnerId,
  }) {
    // 首先发送一次当前位置
    getPartnerLocation(relationId: relationId, partnerId: partnerId)
        .then((loc) {
      if (loc != null && !_partnerLocationController.isClosed) {
        _partnerLocationController.add(loc);
      }
    });

    return partnerLocationStream;
  }

  /// 获取位置历史
  Future<List<LocationShare>> getLocationHistory({
    required String relationId,
    String? userId,
    DateTime? startDate,
    DateTime? endDate,
    int limit = 100,
  }) async {
    await Future.delayed(const Duration(milliseconds: 250));

    final start = startDate ?? DateTime.now().subtract(const Duration(days: 7));
    final end = endDate ?? DateTime.now();

    var filtered = _locationHistory.where((loc) {
      if (loc.relationId != relationId) return false;
      if (userId != null && loc.userId != userId) return false;
      if (loc.timestamp.isBefore(start)) return false;
      if (loc.timestamp.isAfter(end)) return false;
      return true;
    }).toList();

    // 如果没有历史数据，生成一些 Mock 数据
    if (filtered.isEmpty) {
      filtered = _generateMockHistory(relationId, userId ?? 'user_partner', start, end);
    }

    filtered.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return filtered.take(limit).toList();
  }

  /// 更新自己的位置
  Future<LocationShare?> updateMyLocation({
    required String relationId,
    required String userId,
    required double latitude,
    required double longitude,
    double? accuracy,
    double? altitude,
    double? speed,
    double? heading,
  }) async {
    if (!_isSharing) return null;

    await Future.delayed(const Duration(milliseconds: 100));

    _myCurrentLocation = LocationShare(
      objectId: _myCurrentLocation?.objectId ?? 'loc_${DateTime.now().millisecondsSinceEpoch}',
      relationId: relationId,
      userId: userId,
      latitude: latitude,
      longitude: longitude,
      accuracy: accuracy,
      altitude: altitude,
      speed: speed,
      heading: heading,
      timestamp: DateTime.now(),
      expiresAt: _myCurrentLocation?.expiresAt,
      isActive: true,
    );

    _locationHistory.add(_myCurrentLocation!);
    return _myCurrentLocation;
  }

  /// 启动 Mock 搭档位置更新
  void _startMockPartnerUpdates() {
    _mockLocationTimer?.cancel();
    _mockLocationTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      if (!_isSharing) return;

      // 模拟搭档移动
      _mockPartnerLat += (Random().nextDouble() - 0.5) * 0.001;
      _mockPartnerLng += (Random().nextDouble() - 0.5) * 0.001;

      final partnerLocation = LocationShare(
        objectId: 'partner_loc_${DateTime.now().millisecondsSinceEpoch}',
        relationId: _myCurrentLocation?.relationId ?? 'relation_001',
        userId: 'user_partner',
        latitude: _mockPartnerLat,
        longitude: _mockPartnerLng,
        accuracy: 10.0 + Random().nextDouble() * 20,
        altitude: 50.0 + Random().nextDouble() * 10,
        speed: 0.5 + Random().nextDouble() * 2,
        heading: Random().nextDouble() * 360,
        timestamp: DateTime.now(),
        expiresAt: DateTime.now().add(const Duration(minutes: 5)),
        isActive: true,
      );

      if (!_partnerLocationController.isClosed) {
        _partnerLocationController.add(partnerLocation);
      }
    });
  }

  /// 生成 Mock 历史数据
  List<LocationShare> _generateMockHistory(
    String relationId,
    String userId,
    DateTime start,
    DateTime end,
  ) {
    final history = <LocationShare>[];
    double lat = 39.9042;
    double lng = 116.4074;
    DateTime current = start;

    while (current.isBefore(end)) {
      lat += (Random().nextDouble() - 0.5) * 0.002;
      lng += (Random().nextDouble() - 0.5) * 0.002;

      history.add(LocationShare(
        objectId: 'mock_loc_${current.millisecondsSinceEpoch}',
        relationId: relationId,
        userId: userId,
        latitude: lat,
        longitude: lng,
        accuracy: 10.0 + Random().nextDouble() * 30,
        altitude: 40.0 + Random().nextDouble() * 20,
        speed: 0.0 + Random().nextDouble() * 3,
        heading: Random().nextDouble() * 360,
        timestamp: current,
        expiresAt: current.add(const Duration(minutes: 5)),
        isActive: true,
      ));

      current = current.add(Duration(minutes: 5 + Random().nextInt(10)));
    }

    return history;
  }

  /// 释放资源
  void dispose() {
    _mockLocationTimer?.cancel();
    _partnerLocationController.close();
  }
}

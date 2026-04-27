import 'dart:async';

import 'package:get/get.dart';

import '../models/location_share_model.dart';
import '../services/location_service.dart';
import 'user_controller.dart';

/// 位置共享控制器
class LocationController extends GetxController {
  final LocationService _locationService = Get.find<LocationService>();

  /// 我的当前位置
  final Rx<LocationShare?> myLocation = Rx<LocationShare?>(null);

  /// 搭档位置
  final Rx<LocationShare?> partnerLocation = Rx<LocationShare?>(null);

  /// 是否正在共享
  final RxBool isSharing = false.obs;

  /// 位置历史
  final RxList<LocationShare> locationHistory = <LocationShare>[].obs;

  /// 是否加载中
  final RxBool isLoading = false.obs;

  /// 搭档位置 Stream 订阅
  StreamSubscription<LocationShare>? _partnerSubscription;

  /// 当前关系 ID
  String? _relationId;

  /// 当前用户 ID
  String? _userId;

  /// 搭档用户 ID
  String? _partnerId;

  bool get _isAlive => !isClosed;

  @override
  void onInit() {
    super.onInit();
    _loadUserInfo();
  }

  @override
  void onClose() {
    _partnerSubscription?.cancel();
    super.onClose();
  }

  /// 加载用户信息
  Future<void> _loadUserInfo() async {
    try {
      final userController = Get.find<UserController>();
      _userId = userController.currentUser.value?.id ?? 'mock_user_001';
      _partnerId = userController.partnerUser.value?.id ?? 'user_partner';
      _relationId = userController.coupleRelation.value?.id ?? 'relation_001';
    } catch (e) {
      _userId = 'mock_user_001';
      _partnerId = 'user_partner';
      _relationId = 'relation_001';
    }
  }

  /// 开始位置共享
  Future<void> startLocationSharing() async {
    if (!_isAlive) return;

    // 使用 Mock 位置（北京朝阳公园附近）
    const mockLat = 39.9042;
    const mockLng = 116.4074;

    isLoading.value = true;
    try {
      final location = await _locationService.startLocationSharing(
        relationId: _relationId ?? 'relation_001',
        userId: _userId ?? 'mock_user_001',
        latitude: mockLat,
        longitude: mockLng,
        accuracy: 15.0,
        altitude: 50.0,
        speed: 0.5,
        heading: 45.0,
      );

      if (_isAlive) {
        myLocation.value = location;
        isSharing.value = true;
        _subscribePartnerLocation();
        Get.snackbar('成功', '位置共享已开启');
      }
    } catch (e) {
      if (_isAlive) {
        Get.snackbar('错误', '开启位置共享失败');
      }
    } finally {
      if (_isAlive) {
        isLoading.value = false;
      }
    }
  }

  /// 停止位置共享
  Future<void> stopLocationSharing() async {
    if (!_isAlive || !isSharing.value) return;

    isLoading.value = true;
    try {
      await _locationService.stopLocationSharing(
        relationId: _relationId ?? 'relation_001',
        userId: _userId ?? 'mock_user_001',
      );

      if (_isAlive) {
        isSharing.value = false;
        myLocation.value = null;
        partnerLocation.value = null;
        _partnerSubscription?.cancel();
        _partnerSubscription = null;
        Get.snackbar('提示', '位置共享已关闭');
      }
    } catch (e) {
      if (_isAlive) {
        Get.snackbar('错误', '关闭位置共享失败');
      }
    } finally {
      if (_isAlive) {
        isLoading.value = false;
      }
    }
  }

  /// 切换位置共享状态
  Future<void> toggleLocationSharing() async {
    if (isSharing.value) {
      await stopLocationSharing();
    } else {
      await startLocationSharing();
    }
  }

  /// 订阅搭档位置更新
  void _subscribePartnerLocation() {
    _partnerSubscription?.cancel();

    final stream = _locationService.observePartnerLocation(
      relationId: _relationId ?? 'relation_001',
      partnerId: _partnerId ?? 'user_partner',
    );

    _partnerSubscription = stream.listen(
      (location) {
        if (_isAlive) {
          partnerLocation.value = location;
        }
      },
      onError: (e) {
        if (_isAlive) {
          Get.snackbar('错误', '获取搭档位置失败');
        }
      },
    );
  }

  /// 手动更新我的位置
  Future<void> updateMyLocation({
    required double latitude,
    required double longitude,
    double? accuracy,
    double? altitude,
    double? speed,
    double? heading,
  }) async {
    if (!_isAlive || !isSharing.value) return;

    try {
      final updated = await _locationService.updateMyLocation(
        relationId: _relationId ?? 'relation_001',
        userId: _userId ?? 'mock_user_001',
        latitude: latitude,
        longitude: longitude,
        accuracy: accuracy,
        altitude: altitude,
        speed: speed,
        heading: heading,
      );

      if (_isAlive && updated != null) {
        myLocation.value = updated;
      }
    } catch (e) {
      // 忽略更新错误
    }
  }

  /// 获取位置历史
  Future<void> loadLocationHistory({
    DateTime? startDate,
    DateTime? endDate,
    String? userId,
  }) async {
    if (!_isAlive) return;

    isLoading.value = true;
    try {
      final history = await _locationService.getLocationHistory(
        relationId: _relationId ?? 'relation_001',
        userId: userId,
        startDate: startDate,
        endDate: endDate,
        limit: 200,
      );

      if (_isAlive) {
        locationHistory.value = history;
      }
    } catch (e) {
      if (_isAlive) {
        Get.snackbar('错误', '加载位置历史失败');
      }
    } finally {
      if (_isAlive) {
        isLoading.value = false;
      }
    }
  }

  /// 计算与搭档的距离
  String? get distanceToPartner {
    final mine = myLocation.value;
    final partner = partnerLocation.value;

    if (mine == null || partner == null) return null;

    final distance = mine.distanceTo(partner);
    if (distance < 1000) {
      return '${distance.toStringAsFixed(0)}m';
    } else {
      return '${(distance / 1000).toStringAsFixed(2)}km';
    }
  }

  /// 获取我的历史轨迹
  List<LocationShare> get myHistory {
    return locationHistory
        .where((loc) => loc.userId == _userId)
        .toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
  }

  /// 获取搭档历史轨迹
  List<LocationShare> get partnerHistory {
    return locationHistory
        .where((loc) => loc.userId != _userId)
        .toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
  }
}

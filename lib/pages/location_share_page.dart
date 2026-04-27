import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../config/colors.dart';
import '../controllers/location_controller.dart';

/// 位置共享页面
class LocationSharePage extends StatefulWidget {
  const LocationSharePage({super.key});

  @override
  State<LocationSharePage> createState() => _LocationSharePageState();
}

class _LocationSharePageState extends State<LocationSharePage> {
  final LocationController _controller = Get.find<LocationController>();

  // 默认地图中心点（北京）
  static const double _defaultLat = 39.9042;
  static const double _defaultLng = 116.4074;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('位置共享'),
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.gray1,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => Get.toNamed('/location-history'),
            tooltip: '位置历史',
          ),
        ],
      ),
      body: Column(
        children: [
          // 地图区域
          Expanded(
            child: _buildMap(),
          ),
          // 底部状态栏
          _buildBottomBar(),
        ],
      ),
    );
  }

  /// 构建地图区域
  Widget _buildMap() {
    return Container(
      color: AppColors.gray4,
      child: Stack(
        children: [
          // 使用简单地图视图作为占位
          _buildSimpleMapView(),
          // 我的位置标记
          _buildMyLocationMarker(),
          // 搭档位置标记
          _buildPartnerLocationMarker(),
          // 地图控制按钮
          Positioned(
            right: 16,
            bottom: 16,
            child: Column(
              children: [
                _buildMapButton(Icons.my_location, () {
                  // 回到我的位置
                }),
                const SizedBox(height: 8),
                _buildMapButton(Icons.layers, () {
                  // 切换地图类型
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 简单地图视图（模拟）
  Widget _buildSimpleMapView() {
    return Obx(() {
      final myLoc = _controller.myLocation.value;
      final partnerLoc = _controller.partnerLocation.value;

      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.blue.withOpacity(0.1),
              AppColors.green.withOpacity(0.2),
            ],
          ),
        ),
        child: CustomPaint(
          painter: _MapGridPainter(),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.map,
                  size: 80,
                  color: AppColors.gray3.withOpacity(0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  '位置共享地图',
                  style: TextStyle(
                    color: AppColors.gray3,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  myLoc != null || partnerLoc != null
                      ? '实时更新中...'
                      : '点击下方按钮开启位置共享',
                  style: TextStyle(
                    color: AppColors.gray3.withOpacity(0.7),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  /// 我的位置标记
  Widget _buildMyLocationMarker() {
    return Obx(() {
      final myLoc = _controller.myLocation.value;
      if (myLoc == null) return const SizedBox.shrink();

      return Positioned(
        left: 100,
        top: 150,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.blue,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.blue.withOpacity(0.4),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Icon(
                Icons.person,
                color: AppColors.white,
                size: 24,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.blue,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                '我',
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  /// 搭档位置标记
  Widget _buildPartnerLocationMarker() {
    return Obx(() {
      final partnerLoc = _controller.partnerLocation.value;
      if (partnerLoc == null) return const SizedBox.shrink();

      return Positioned(
        right: 120,
        top: 200,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.4),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Icon(
                Icons.person,
                color: AppColors.white,
                size: 24,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                '另一半',
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  /// 地图按钮
  Widget _buildMapButton(IconData icon, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: AppColors.gray1),
        onPressed: onPressed,
      ),
    );
  }

  /// 底部状态栏
  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 状态信息
            Obx(() => _buildStatusInfo()),
            const SizedBox(height: 16),
            // 开启/关闭按钮
            Obx(() => _buildToggleButton()),
          ],
        ),
      ),
    );
  }

  /// 状态信息
  Widget _buildStatusInfo() {
    final isSharing = _controller.isSharing.value;
    final distance = _controller.distanceToPartner;
    final myLoc = _controller.myLocation.value;
    final partnerLoc = _controller.partnerLocation.value;

    if (!isSharing) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.gray4,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              Icons.location_off,
              color: AppColors.gray3,
              size: 32,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '位置共享已关闭',
                    style: TextStyle(
                      color: AppColors.gray2,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '开启后可以实时查看彼此的位置',
                    style: TextStyle(
                      color: AppColors.gray3,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.blue.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: AppColors.green,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '正在共享位置',
                style: TextStyle(
                  color: AppColors.green,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              if (distance != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.straighten,
                        size: 14,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '相距 $distance',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildInfoChip(
                  icon: Icons.my_location,
                  label: '我的位置',
                  value: myLoc != null
                      ? '${myLoc.latitude.toStringAsFixed(4)}, ${myLoc.longitude.toStringAsFixed(4)}'
                      : '获取中...',
                  color: AppColors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildInfoChip(
                  icon: Icons.person,
                  label: '另一半',
                  value: partnerLoc != null
                      ? '${partnerLoc.latitude.toStringAsFixed(4)}, ${partnerLoc.longitude.toStringAsFixed(4)}'
                      : '获取中...',
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 信息芯片
  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: AppColors.gray1,
              fontSize: 12,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  /// 开启/关闭按钮
  Widget _buildToggleButton() {
    final isSharing = _controller.isSharing.value;
    final isLoading = _controller.isLoading.value;

    if (isLoading) {
      return SizedBox(
        width: double.infinity,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.gray3,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
              ),
            ),
          ),
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => _controller.toggleLocationSharing(),
        style: ElevatedButton.styleFrom(
          backgroundColor: isSharing ? AppColors.gray2 : AppColors.primary,
          foregroundColor: AppColors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(isSharing ? Icons.location_off : Icons.location_on),
            const SizedBox(width: 8),
            Text(
              isSharing ? '关闭位置共享' : '开启位置共享',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 地图网格绘制器
class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.gray5.withOpacity(0.5)
      ..strokeWidth = 0.5;

    const double gridSize = 30;

    for (double x = 0; x < size.width; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    for (double y = 0; y < size.height; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

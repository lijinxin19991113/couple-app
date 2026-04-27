import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../config/colors.dart';
import '../controllers/location_controller.dart';
import '../models/location_share_model.dart';

/// 位置历史页面
class LocationHistoryPage extends StatefulWidget {
  const LocationHistoryPage({super.key});

  @override
  State<LocationHistoryPage> createState() => _LocationHistoryPageState();
}

class _LocationHistoryPageState extends State<LocationHistoryPage> {
  final LocationController _controller = Get.find<LocationController>();
  DateTime _selectedDate = DateTime.now();
  String _selectedUserId = 'all'; // 'all', 'me', 'partner'

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  void _loadHistory() {
    final startDate = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
    final endDate = startDate.add(const Duration(days: 1));
    
    String? userId;
    if (_selectedUserId == 'me') {
      userId = _controller.myLocation.value?.userId;
    } else if (_selectedUserId == 'partner') {
      userId = _controller.partnerLocation.value?.userId;
    }

    _controller.loadLocationHistory(
      startDate: startDate,
      endDate: endDate,
      userId: userId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('位置历史'),
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.gray1,
        elevation: 0,
      ),
      body: Column(
        children: [
          // 日期选择器
          _buildDateSelector(),
          // 用户筛选
          _buildUserFilter(),
          // 轨迹地图
          _buildTrailMap(),
          // 历史列表
          Expanded(
            child: _buildHistoryList(),
          ),
        ],
      ),
    );
  }

  /// 日期选择器
  Widget _buildDateSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: AppColors.white,
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () {
              setState(() {
                _selectedDate = _selectedDate.subtract(const Duration(days: 1));
              });
              _loadHistory();
            },
            color: AppColors.gray2,
          ),
          Expanded(
            child: GestureDetector(
              onTap: _showDatePicker,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 18,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _formatDate(_selectedDate),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.gray1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: _selectedDate.isBefore(DateTime.now().subtract(const Duration(days: 1)))
                ? () {
                    setState(() {
                      _selectedDate = _selectedDate.add(const Duration(days: 1));
                    });
                    _loadHistory();
                  }
                : null,
            color: AppColors.gray2,
          ),
        ],
      ),
    );
  }

  /// 用户筛选
  Widget _buildUserFilter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: AppColors.white,
      child: Row(
        children: [
          _buildFilterChip('全部', 'all'),
          const SizedBox(width: 8),
          _buildFilterChip('我的', 'me'),
          const SizedBox(width: 8),
          _buildFilterChip('另一半', 'partner'),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedUserId == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedUserId = value;
        });
        _loadHistory();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.gray4,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppColors.white : AppColors.gray2,
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  /// 轨迹地图
  Widget _buildTrailMap() {
    return Container(
      height: 200,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.gray4,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Obx(() {
        final history = _controller.locationHistory;
        
        if (history.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.route,
                  size: 48,
                  color: AppColors.gray3.withOpacity(0.5),
                ),
                const SizedBox(height: 8),
                Text(
                  '暂无轨迹数据',
                  style: TextStyle(
                    color: AppColors.gray3,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          );
        }

        return ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: CustomPaint(
            painter: _TrailPainter(history: history),
            child: Container(),
          ),
        );
      }),
    );
  }

  /// 历史列表
  Widget _buildHistoryList() {
    return Obx(() {
      final history = _controller.locationHistory;

      if (_controller.isLoading.value) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      }

      if (history.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.history,
                size: 64,
                color: AppColors.gray3.withOpacity(0.5),
              ),
              const SizedBox(height: 16),
              Text(
                '暂无位置记录',
                style: TextStyle(
                  color: AppColors.gray3,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '选择其他日期试试',
                style: TextStyle(
                  color: AppColors.gray3.withOpacity(0.7),
                  fontSize: 13,
                ),
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: history.length,
        itemBuilder: (context, index) {
          final location = history[index];
          final isMe = location.userId == _controller.myLocation.value?.userId ||
              location.userId == 'mock_user_001';
          
          return _buildHistoryItem(location, isMe);
        },
      );
    });
  }

  Widget _buildHistoryItem(LocationShare location, bool isMe) {
    final timeFormat = DateFormat('HH:mm:ss');
    final dateFormat = DateFormat('yyyy-MM-dd');

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.04),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isMe ? AppColors.blue.withOpacity(0.1) : AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isMe ? Icons.my_location : Icons.person,
              color: isMe ? AppColors.blue : AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      isMe ? '我的位置' : '另一半',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: AppColors.gray1,
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (location.speed != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          location.formattedSpeed ?? '',
                          style: TextStyle(
                            color: AppColors.green,
                            fontSize: 11,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${location.latitude.toStringAsFixed(6)}, ${location.longitude.toStringAsFixed(6)}',
                  style: TextStyle(
                    color: AppColors.gray3,
                    fontSize: 12,
                  ),
                ),
                if (location.accuracy != null)
                  Text(
                    '精度: ${location.accuracy!.toStringAsFixed(1)}m',
                    style: TextStyle(
                      color: AppColors.gray3.withOpacity(0.7),
                      fontSize: 11,
                    ),
                  ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                timeFormat.format(location.timestamp),
                style: TextStyle(
                  color: AppColors.gray2,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                dateFormat.format(location.timestamp),
                style: TextStyle(
                  color: AppColors.gray3,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final targetDate = DateTime(date.year, date.month, date.day);

    if (targetDate == today) {
      return '今天 (${DateFormat('MM月dd日').format(date)})';
    } else if (targetDate == yesterday) {
      return '昨天 (${DateFormat('MM月dd日').format(date)})';
    } else {
      return DateFormat('yyyy年MM月dd日').format(date);
    }
  }

  void _showDatePicker() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().subtract(const Duration(days: 1)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: AppColors.white,
              surface: AppColors.white,
              onSurface: AppColors.gray1,
            ),
          ),
          child: child!,
        );
      },
    );

    if (!mounted) return;
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      _loadHistory();
    }
  }
}

/// 轨迹绘制器
class _TrailPainter extends CustomPainter {
  final List<LocationShare> history;

  _TrailPainter({required this.history});

  @override
  void paint(Canvas canvas, Size size) {
    if (history.isEmpty) return;

    // 简单的轨迹可视化
    final paint = Paint()
      ..color = AppColors.primary.withOpacity(0.6)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final bgPaint = Paint()
      ..color = AppColors.gray4
      ..style = PaintingStyle.fill;

    // 绘制背景
    canvas.drawRect(Offset.zero & size, bgPaint);

    // 计算缩放比例
    double minLat = 90, maxLat = -90, minLng = 180, maxLng = -180;
    for (final loc in history) {
      if (loc.latitude < minLat) minLat = loc.latitude;
      if (loc.latitude > maxLat) maxLat = loc.latitude;
      if (loc.longitude < minLng) minLng = loc.longitude;
      if (loc.longitude > maxLng) maxLng = loc.longitude;
    }

    // 添加一些边距
    final latRange = maxLat - minLat + 0.01;
    final lngRange = maxLng - minLng + 0.01;

    // 绘制轨迹
    final path = Path();
    bool first = true;

    for (final loc in history) {
      final x = ((loc.longitude - minLng) / lngRange) * (size.width - 20) + 10;
      final y = size.height - (((loc.latitude - minLat) / latRange) * (size.height - 20) + 10);

      if (first) {
        path.moveTo(x, y);
        first = false;
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);

    // 绘制起点和终点
    if (history.isNotEmpty) {
      final start = history.first;
      final end = history.last;

      final startX = ((start.longitude - minLng) / lngRange) * (size.width - 20) + 10;
      final startY = size.height - (((start.latitude - minLat) / latRange) * (size.height - 20) + 10);

      final endX = ((end.longitude - minLng) / lngRange) * (size.width - 20) + 10;
      final endY = size.height - (((end.latitude - minLat) / latRange) * (size.height - 20) + 10);

      // 起点 - 蓝色
      final startPaint = Paint()
        ..color = AppColors.blue
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(startX, startY), 6, startPaint);

      // 终点 - 粉色
      final endPaint = Paint()
        ..color = AppColors.primary
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(endX, endY), 6, endPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _TrailPainter oldDelegate) {
    return oldDelegate.history != history;
  }
}

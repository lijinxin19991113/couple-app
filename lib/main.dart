import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'app/app.dart';
import 'config/theme.dart';
import 'controllers/auth_controller.dart';
import 'controllers/user_controller.dart';

/// 应用入口
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 强制竖屏
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // 初始化 Hive（本地结构化存储）
  await Hive.initFlutter();

  // 初始化安全存储（Token等敏感信息）
  const secureStorage = FlutterSecureStorage();
  Get.put<FlutterSecureStorage>(secureStorage, permanent: true);

  // 注册全局控制器
  Get.put<AuthController>(AuthController(), permanent: true);
  Get.put<UserController>(UserController(), permanent: true);

  runApp(const CoupleApp());
}

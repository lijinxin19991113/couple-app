import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';

import 'app/app.dart';
import 'controllers/album_controller.dart';
import 'controllers/auth_controller.dart';
import 'controllers/user_controller.dart';
import 'core/storage/storage_service.dart';
import 'services/album_service.dart';

/// 应用入口
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 强制竖屏
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // 初始化安全存储（Token等敏感信息）
  const secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );
  Get.put<FlutterSecureStorage>(secureStorage, permanent: true);

  // 初始化 StorageService（GetxService，支持 async init）
  final storageService = StorageService();
  await storageService.init();
  Get.put<StorageService>(storageService, permanent: true);

  // 初始化 AlbumService
  Get.put<AlbumService>(AlbumService(), permanent: true);

  // 注册全局控制器
  Get.put<AuthController>(AuthController(), permanent: true);
  Get.put<UserController>(UserController(), permanent: true);
  Get.put<AlbumController>(AlbumController(), permanent: true);

  runApp(const CoupleApp());
}

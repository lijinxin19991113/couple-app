import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';

import '../config/constants.dart';
import '../models/user_model.dart';

/// 认证控制器 - 处理登录注册流程
class AuthController extends GetxController {
  final FlutterSecureStorage _storage = Get.find<FlutterSecureStorage>();

  /// 是否已登录
  final RxBool isLoggedIn = false.obs;

  /// 是否正在加载
  final RxBool isLoading = false.obs;

  /// 当前用户
  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);

  @override
  void onInit() {
    super.onInit();
    _initAuth();
  }

  /// 初始化认证状态
  Future<void> _initAuth() async {
    final token = await _storage.read(key: AppConstants.keyAccessToken);
    if (token != null && token.isNotEmpty) {
      isLoggedIn.value = true;
    }
  }

  /// 检查登录状态
  Future<void> checkLoginStatus() async {
    isLoading.value = true;
    try {
      final token = await _storage.read(key: AppConstants.keyAccessToken);
      if (token != null && token.isNotEmpty) {
        isLoggedIn.value = true;
        // TODO: 调用接口验证 Token 有效性
      } else {
        isLoggedIn.value = false;
      }
    } catch (e) {
      isLoggedIn.value = false;
    } finally {
      isLoading.value = false;
    }
  }

  /// 发送验证码
  Future<bool> sendCode(String phone) async {
    isLoading.value = true;
    try {
      // TODO: 调用发送验证码接口
      // final result = await ApiClient(_storage).post('/auth/sendCode', data: {'phone': phone});
      await Future.delayed(const Duration(seconds: 1)); // 模拟
      return true;
    } catch (e) {
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// 验证码登录
  Future<bool> loginWithCode(String phone, String code) async {
    isLoading.value = true;
    try {
      // TODO: 调用验证码登录接口
      // final result = await ApiClient(_storage).post('/auth/login', data: {
      //   'phone': phone,
      //   'code': code,
      // });
      // if (result.success) {
      //   await _saveAuth(result.data);
      //   return true;
      // }

      // 模拟登录成功
      await _saveMockAuth(phone);
      return true;
    } catch (e) {
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// 注册
  Future<bool> register({
    required String phone,
    required String nickname,
    required String code,
    required String password,
    required String gender,
  }) async {
    isLoading.value = true;
    try {
      // TODO: 调用注册接口
      // final result = await ApiClient(_storage).post('/auth/register', data: {
      //   'phone': phone,
      //   'nickname': nickname,
      //   'code': code,
      //   'password': password,
      //   'gender': gender,
      // });
      // if (result.success) {
      //   await _saveAuth(result.data);
      //   return true;
      // }

      // 模拟注册成功
      await _saveMockAuth(phone, nickname: nickname);
      return true;
    } catch (e) {
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// 保存认证信息
  Future<void> _saveAuth(Map<String, dynamic> data) async {
    final accessToken = data['access_token'] as String?;
    final refreshToken = data['refresh_token'] as String?;

    if (accessToken != null) {
      await _storage.write(key: AppConstants.keyAccessToken, value: accessToken);
    }
    if (refreshToken != null) {
      await _storage.write(key: AppConstants.keyRefreshToken, value: refreshToken);
    }

    isLoggedIn.value = true;
  }

  /// 保存模拟认证（开发用）
  Future<void> _saveMockAuth(String phone, {String? nickname}) async {
    await _storage.write(key: AppConstants.keyAccessToken, value: 'mock_token_$phone');
    await _storage.write(
      key: AppConstants.keyUserInfo,
      value: '{"id": "mock_user_001", "nickname": "${nickname ?? "用户"}", "phone": "$phone"}',
    );
    isLoggedIn.value = true;
    currentUser.value = UserModel(
      id: 'mock_user_001',
      nickname: nickname ?? '用户',
      phone: phone,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// 退出登录
  Future<void> logout() async {
    isLoading.value = true;
    try {
      // 清除本地存储
      await _storage.delete(key: AppConstants.keyAccessToken);
      await _storage.delete(key: AppConstants.keyRefreshToken);
      await _storage.delete(key: AppConstants.keyUserInfo);

      isLoggedIn.value = false;
      currentUser.value = null;

      // TODO: 调用后端退出接口
    } catch (e) {
      // 忽略错误
    } finally {
      isLoading.value = false;
    }
  }

  /// 获取 Token
  Future<String?> getToken() async {
    return await _storage.read(key: AppConstants.keyAccessToken);
  }
}

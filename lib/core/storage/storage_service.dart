import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 本地存储服务
/// 敏感信息使用 FlutterSecureStorage
/// 普通数据使用 SharedPreferences
class StorageService {
  late final SharedPreferences _prefs;
  final FlutterSecureStorage _secureStorage = Get.find<FlutterSecureStorage>();

  /// 初始化
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // ===== 普通数据存储（SharedPreferences） =====

  /// 存储字符串
  Future<bool> setString(String key, String value) {
    return _prefs.setString(key, value);
  }

  /// 获取字符串
  String? getString(String key) {
    return _prefs.getString(key);
  }

  /// 存储整数
  Future<bool> setInt(String key, int value) {
    return _prefs.setInt(key, value);
  }

  /// 获取整数
  int? getInt(String key) {
    return _prefs.getInt(key);
  }

  /// 存储布尔
  Future<bool> setBool(String key, bool value) {
    return _prefs.setBool(key, value);
  }

  /// 获取布尔
  bool? getBool(String key) {
    return _prefs.getBool(key);
  }

  /// 存储 JSON 对象
  Future<bool> setJson(String key, Map<String, dynamic> value) {
    return _prefs.setString(key, jsonEncode(value));
  }

  /// 获取 JSON 对象
  Map<String, dynamic>? getJson(String key) {
    final str = _prefs.getString(key);
    if (str == null) return null;
    return jsonDecode(str) as Map<String, dynamic>;
  }

  /// 存储字符串列表
  Future<bool> setStringList(String key, List<String> value) {
    return _prefs.setStringList(key, value);
  }

  /// 获取字符串列表
  List<String>? getStringList(String key) {
    return _prefs.getStringList(key);
  }

  /// 删除
  Future<bool> remove(String key) {
    return _prefs.remove(key);
  }

  /// 清空
  Future<bool> clear() {
    return _prefs.clear();
  }

  /// 是否包含
  bool containsKey(String key) {
    return _prefs.containsKey(key);
  }

  // ===== 敏感数据存储（FlutterSecureStorage） =====

  /// 安全存储 Token
  Future<void> saveToken(String accessToken, String? refreshToken) async {
    await _secureStorage.write(key: 'access_token', value: accessToken);
    if (refreshToken != null) {
      await _secureStorage.write(key: 'refresh_token', value: refreshToken);
    }
  }

  /// 获取 Access Token
  Future<String?> getAccessToken() async {
    return await _secureStorage.read(key: 'access_token');
  }

  /// 获取 Refresh Token
  Future<String?> getRefreshToken() async {
    return await _secureStorage.read(key: 'refresh_token');
  }

  /// 删除 Token
  Future<void> clearToken() async {
    await _secureStorage.delete(key: 'access_token');
    await _secureStorage.delete(key: 'refresh_token');
  }

  /// 安全存储用户信息
  Future<void> saveUserInfo(Map<String, dynamic> userInfo) async {
    await _secureStorage.write(
      key: 'user_info',
      value: jsonEncode(userInfo),
    );
  }

  /// 获取用户信息
  Future<Map<String, dynamic>?> getUserInfo() async {
    final str = await _secureStorage.read(key: 'user_info');
    if (str == null) return null;
    return jsonDecode(str) as Map<String, dynamic>;
  }

  /// 清除所有安全存储
  Future<void> clearAllSecure() async {
    await _secureStorage.deleteAll();
  }
}

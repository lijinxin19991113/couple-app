import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

import '../../config/constants.dart';

/// API 响应结果
class ApiResult<T> {
  final bool success;
  final T? data;
  final String? message;
  final int? code;

  ApiResult({required this.success, this.data, this.message, this.code});
}

/// Dio 网络客户端封装
class ApiClient {
  late final Dio _dio;
  late final Dio _refreshDio; // 独立的 Dio 实例用于刷新 Token，避免拦截器递归
  final FlutterSecureStorage _storage;
  final Logger _logger = Logger(printer: PrettyPrinter(printTime: true));

  /// Token 刷新互斥锁，防止并发刷新
  bool _isRefreshing = false;

  /// 刷新成功后等待重试的请求队列（每个请求自己的 Completer）
  final List<_QueuedRequest> _queuedRequests = [];

  ApiClient(this._storage) {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.apiBaseUrl,
        connectTimeout: Duration(milliseconds: AppConstants.apiTimeout),
        receiveTimeout: Duration(milliseconds: AppConstants.apiTimeout),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // 独立的 Dio 用于刷新 Token，不经过拦截器避免死循环
    _refreshDio = Dio(
      BaseOptions(
        baseUrl: AppConstants.apiBaseUrl,
        connectTimeout: Duration(milliseconds: AppConstants.apiTimeout),
        receiveTimeout: Duration(milliseconds: AppConstants.apiTimeout),
      ),
    );

    _dio.interceptors.addAll([
      _AuthInterceptor(this),
      _LoggingInterceptor(_logger),
    ]);
  }

  /// GET 请求
  Future<ApiResult<T>> get<T>(
    String path, {
    Map<String, dynamic>? params,
    Options? options,
  }) async {
    try {
      final response = await _dio.get<T>(
        path,
        queryParameters: params,
        options: options,
      );
      return ApiResult(success: true, data: response.data);
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  /// POST 请求
  Future<ApiResult<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? params,
    Options? options,
  }) async {
    try {
      final response = await _dio.post<T>(
        path,
        data: data,
        queryParameters: params,
        options: options,
      );
      return ApiResult(success: true, data: response.data);
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  /// PUT 请求
  Future<ApiResult<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? params,
    Options? options,
  }) async {
    try {
      final response = await _dio.put<T>(
        path,
        data: data,
        queryParameters: params,
        options: options,
      );
      return ApiResult(success: true, data: response.data);
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  /// DELETE 请求
  Future<ApiResult<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? params,
    Options? options,
  }) async {
    try {
      final response = await _dio.delete<T>(
        path,
        data: data,
        queryParameters: params,
        options: options,
      );
      return ApiResult(success: true, data: response.data);
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  /// 文件上传
  Future<ApiResult<T>> uploadFile<T>(
    String path,
    String filePath, {
    String fieldName = 'file',
    Map<String, dynamic>? params,
    void Function(int, int)? onSendProgress,
  }) async {
    try {
      final formData = FormData.fromMap({
        fieldName: await MultipartFile.fromFile(filePath),
        ...?params,
      });

      final response = await _dio.post<T>(
        path,
        data: formData,
        onSendProgress: onSendProgress,
      );
      return ApiResult(success: true, data: response.data);
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  /// 处理错误
  ApiResult<T> _handleError<T>(DioException e) {
    String message;
    int code;

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        message = '连接超时，请检查网络';
        code = -1;
        break;
      case DioExceptionType.sendTimeout:
        message = '发送超时，请重试';
        code = -2;
        break;
      case DioExceptionType.receiveTimeout:
        message = '接收超时，请重试';
        code = -3;
        break;
      case DioExceptionType.badResponse:
        code = e.response?.statusCode ?? 0;
        message = _parseErrorMessage(e.response?.data) ?? '请求失败';
        break;
      case DioExceptionType.cancel:
        message = '请求已取消';
        code = -4;
        break;
      case DioExceptionType.connectionError:
        message = '网络连接失败，请检查网络';
        code = -5;
        break;
      default:
        message = '网络异常，请重试';
        code = -6;
    }

    _logger.e('API Error: $message (code: $code)');
    return ApiResult(success: false, message: message, code: code);
  }

  /// 解析错误消息
  String? _parseErrorMessage(dynamic data) {
    if (data == null) return null;
    if (data is String) return data;
    if (data is Map) return data['message'] ?? data['error'];
    return null;
  }

  /// Token 刷新（互斥锁 + 队列等待）
  ///
  /// 并发 401 处理流程：
  /// - 第一个 401：加锁，发起刷新请求
  /// - 后续 401（在刷新中）：加入 _queuedRequests 队列，等待刷新完成
  /// - 刷新成功：用新 Token 重试所有队列请求
  /// - 刷新失败：所有队列请求均以 401 拒绝，并清除本地 Token
  Future<String?> _refreshToken() async {
    // 如果已经在刷新中，加入队列等待
    if (_isRefreshing) {
      return _waitForRefresh();
    }

    _isRefreshing = true;

    try {
      final refreshToken = await _storage.read(key: AppConstants.keyRefreshToken);
      if (refreshToken == null) {
        _notifyAll(null); // 无 refreshToken，通知所有等待的请求失败
        return null;
      }

      final response = await _refreshDio.post(
        '${AppConstants.apiBaseUrl}/auth/refresh',
        data: {'refresh_token': refreshToken},
      );

      String? newToken;

      if (response.statusCode == 200 && response.data != null) {
        newToken = response.data['access_token'] as String?;
        if (newToken != null) {
          await _storage.write(key: AppConstants.keyAccessToken, value: newToken);
        }
      }

      _notifyAll(newToken); // 通知所有等待的请求
      return newToken;
    } catch (e) {
      _logger.e('Token refresh failed: $e');
      _notifyAll(null); // 刷新异常，通知所有等待的请求失败
      return null;
    } finally {
      _isRefreshing = false;
    }
  }

  /// 刷新进行中时加入队列，等待刷新完成后被通知
  Future<String?> _waitForRefresh() async {
    final completer = Completer<String?>();
    _queuedRequests.add(_QueuedRequest(completer: completer));
    return completer.future;
  }

  /// 刷新完成后，通知所有等待的请求
  void _notifyAll(String? newToken) {
    for (final req in _queuedRequests) {
      req.complete(newToken);
    }
    _queuedRequests.clear();
  }

  /// 处理单个 401 请求：刷新 Token 并重试该请求
  /// 返回重试后的 Response，刷新失败返回 null
  Future<Response?> _handle401(RequestOptions options) async {
    final newToken = await _refreshToken();

    if (newToken != null) {
      // 刷新成功：用新 Token 重试该请求
      options.headers['Authorization'] = 'Bearer $newToken';
      try {
        return await _dio.fetch(options);
      } catch (e) {
        // 重试失败，返回 null，由调用方走原始错误流程
        return null;
      }
    } else {
      // 刷新失败：清除本地 Token
      await _storage.delete(key: AppConstants.keyAccessToken);
      await _storage.delete(key: AppConstants.keyRefreshToken);
      return null;
    }
  }
}

/// 待重试的请求封装
class _QueuedRequest {
  final Completer<String?> completer;

  _QueuedRequest({required this.completer});

  void complete(String? token) {
    if (!completer.isCompleted) completer.complete(token);
  }
}

/// 认证拦截器 - 自动添加 Token
class _AuthInterceptor extends Interceptor {
  final ApiClient _client;

  _AuthInterceptor(this._client);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // 跳过 Token 刷新接口本身，避免死循环
    if (options.path.endsWith('/auth/refresh')) {
      return handler.next(options);
    }

    final storage = Get.find<FlutterSecureStorage>();
    final token = await storage.read(key: AppConstants.keyAccessToken);
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // 仅处理 401，且非刷新接口
    if (err.response?.statusCode == 401 &&
        !err.requestOptions.path.endsWith('/auth/refresh')) {
      // 刷新 Token 并重试
      final retryResponse = await _client._handle401(err.requestOptions);
      if (retryResponse != null) {
        // 刷新成功，返回重试后的响应
        handler.resolve(retryResponse);
      } else {
        // 刷新失败，沿用原始 401 错误
        handler.next(err);
      }
    } else {
      handler.next(err);
    }
  }
}

/// 日志拦截器
class _LoggingInterceptor extends Interceptor {
  final Logger _logger;

  _LoggingInterceptor(this._logger);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _logger.i('[API] ${options.method} ${options.path}');
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    _logger.i('[API] ${response.statusCode} ${response.requestOptions.path}');
    handler.next(response);
  }

  @override
  void onError(DioException err, ResponseInterceptorHandler handler) {
    _logger.e('[API] Error: ${err.message}');
    handler.next(err);
  }
}

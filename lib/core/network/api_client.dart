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

  /// 等待刷新的请求队列
  final List<_RequestCompleter> _pendingRequests = [];

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

  /// Token 刷新（互斥锁 + 重试上限）
  Future<String?> _refreshToken() async {
    if (_isRefreshing) return null;

    _isRefreshing = true;

    try {
      final refreshToken = await _storage.read(key: AppConstants.keyRefreshToken);
      if (refreshToken == null) {
        return null;
      }

      // 使用独立 Dio 实例，避免拦截器递归
      final response = await _refreshDio.post(
        '${AppConstants.apiBaseUrl}/auth/refresh',
        data: {'refresh_token': refreshToken},
      );

      if (response.statusCode == 200 && response.data != null) {
        final newToken = response.data['access_token'] as String?;
        if (newToken != null) {
          await _storage.write(key: AppConstants.keyAccessToken, value: newToken);
          return newToken;
        }
      }

      return null;
    } catch (e) {
      _logger.e('Token refresh failed: $e');
      return null;
    } finally {
      _isRefreshing = false;
    }
  }

  /// 处理 401：刷新 Token 并重试所有等待的请求
  Future<void> _handleUnauthorized(List<_RequestCompleter> pending) async {
    final newToken = await _refreshToken();

    if (newToken != null) {
      // 全部成功，重试所有请求
      for (final completer in pending) {
        completer.requestOptions.headers['Authorization'] = 'Bearer $newToken';
        _dio.fetch(completer.requestOptions).then(
          (response) => completer.resolve(response),
          onError: (error) => completer.reject(error as DioException),
        );
      }
    } else {
      // 刷新失败，全部标记为 401
      for (final completer in pending) {
        completer.reject(
          DioException(
            requestOptions: completer.requestOptions,
            response: Response(
              requestOptions: completer.requestOptions,
              statusCode: 401,
            ),
          ),
        );
      }
    }
  }
}

/// 辅助类：存储待重试的请求
class _RequestCompleter {
  final RequestOptions requestOptions;
  final Completer<Response> completer;

  _RequestCompleter(this.requestOptions) : completer = Completer<Response>();

  void resolve(Response response) => completer.complete(response);
  void reject(DioException error) => completer.completeError(error);
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
      // 使用独立 Dio 实例调用刷新接口
      final storage = Get.find<FlutterSecureStorage>();
      final refreshToken = await storage.read(key: AppConstants.keyRefreshToken);

      if (refreshToken != null) {
        final newToken = await _client._refreshToken();

        if (newToken != null) {
          // 更新 Token 并重试一次（不通过拦截器，避免循环）
          err.requestOptions.headers['Authorization'] = 'Bearer $newToken';
          try {
            final retryResponse = await Dio().fetch(err.requestOptions);
            return handler.resolve(retryResponse);
          } catch (e) {
            return handler.next(err);
          }
        }
      }

      // 刷新失败或无 refreshToken，清除 Token
      await storage.delete(key: AppConstants.keyAccessToken);
      await storage.delete(key: AppConstants.keyRefreshToken);
    }

    handler.next(err);
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
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _logger.e('[API] Error: ${err.message}');
    handler.next(err);
  }
}

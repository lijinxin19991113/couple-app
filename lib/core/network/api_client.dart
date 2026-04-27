import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart' as getx;
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
  final FlutterSecureStorage _storage;
  final Logger _logger = Logger(printer: PrettyPrinter(printTime: true));

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

    // 添加拦截器
    _dio.interceptors.addAll([
      _AuthInterceptor(_storage, _dio),
      _LoggingInterceptor(_logger),
      _ErrorInterceptor(),
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
}

/// 认证拦截器 - 自动添加 Token
class _AuthInterceptor extends Interceptor {
  final FlutterSecureStorage _storage;
  final Dio _dio;

  _AuthInterceptor(this._storage, this._dio);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // 读取 Token
    final token = await _storage.read(key: AppConstants.keyAccessToken);
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // 如果是 401，尝试刷新 Token
    if (err.response?.statusCode == 401) {
      final refreshToken = await _storage.read(key: AppConstants.keyRefreshToken);
      if (refreshToken != null) {
        try {
          // 刷新 Token
          final response = await _dio.post(
            '/auth/refresh',
            data: {'refresh_token': refreshToken},
          );

          if (response.statusCode == 200) {
            final newToken = response.data['access_token'];
            await _storage.write(
              key: AppConstants.keyAccessToken,
              value: newToken,
            );

            // 重试原请求
            err.requestOptions.headers['Authorization'] = 'Bearer $newToken';
            final retryResponse = await _dio.fetch(err.requestOptions);
            return handler.resolve(retryResponse);
          }
        } catch (_) {
          // 刷新失败，清除 Token
          await _storage.delete(key: AppConstants.keyAccessToken);
          await _storage.delete(key: AppConstants.keyRefreshToken);
        }
      }
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

/// 错误拦截器
class _ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // 统一错误处理
    handler.next(err);
  }
}

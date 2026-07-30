import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import '../core/constants/api_constants.dart';
import '../core/errors/exceptions.dart';
import 'storage_service.dart';

class ApiService {
  late final Dio _dio;
  final StorageService _storageService;

  ApiService(this._storageService) {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(milliseconds: ApiConstants.connectTimeout),
        receiveTimeout: const Duration(milliseconds: ApiConstants.receiveTimeout),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.addAll([
      _AuthInterceptor(_storageService),
      _ErrorInterceptor(),
      if (kDebugMode) PrettyDioLogger(
        requestHeader: false,
        requestBody: true,
        responseBody: true,
        responseHeader: false,
        compact: true,
      ),
    ]);
  }

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _dio.get<T>(
      path,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _dio.post<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _dio.put<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _dio.delete<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }
}

class _AuthInterceptor extends Interceptor {
  final StorageService _storageService;

  _AuthInterceptor(this._storageService);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _storageService.getToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
}

class _ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final response = err.response;

    if (err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.sendTimeout) {
      handler.reject(
        DioException(
          requestOptions: err.requestOptions,
          error: const TimeoutException(),
          type: err.type,
        ),
      );
      return;
    }

    if (err.type == DioExceptionType.connectionError) {
      handler.reject(
        DioException(
          requestOptions: err.requestOptions,
          error: const NetworkException(),
          type: err.type,
        ),
      );
      return;
    }

    if (response != null) {
      final statusCode = response.statusCode;
      final message = _extractMessage(response.data);

      AppException exception;
      switch (statusCode) {
        case 401:
          exception = UnauthorizedException(message);
          break;
        case 403:
          exception = ForbiddenException(message);
          break;
        case 404:
          exception = NotFoundException(message);
          break;
        case 422:
          exception = ValidationException(message);
          break;
        case 500:
        default:
          exception = ServerException(message);
      }

      handler.reject(
        DioException(
          requestOptions: err.requestOptions,
          error: exception,
          response: response,
          type: err.type,
        ),
      );
      return;
    }

    handler.next(err);
  }

  String _extractMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data['message'] as String? ??
          data['error'] as String? ??
          'An error occurred';
    }
    return 'An error occurred';
  }
}

AppException mapDioError(DioException e) {
  if (e.error is AppException) return e.error as AppException;

  switch (e.type) {
    case DioExceptionType.connectionError:
      return const NetworkException();
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.receiveTimeout:
    case DioExceptionType.sendTimeout:
      return const TimeoutException();
    default:
      return AppException(e.message ?? 'An error occurred');
  }
}

import 'package:dio/dio.dart';

import 'package:lexcore/core/error/app_exception.dart';
import 'package:lexcore/core/network/api_envelope.dart';

class ApiClient {
  ApiClient(this._dio);

  final Dio _dio;

  Future<T> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    required T Function(Object? data) decoder,
  }) async {
    try {
      final response = await _dio.get<dynamic>(
        path,
        queryParameters: queryParameters,
        options: options,
      );
      return _decodeResponse(response, decoder: decoder);
    } on DioException catch (error) {
      throw _mapDioException(error);
    }
  }

  Future<T> post<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    required T Function(Object? data) decoder,
  }) async {
    try {
      final response = await _dio.post<dynamic>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return _decodeResponse(response, decoder: decoder);
    } on DioException catch (error) {
      throw _mapDioException(error);
    }
  }

  Future<T> patch<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    required T Function(Object? data) decoder,
  }) async {
    try {
      final response = await _dio.patch<dynamic>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return _decodeResponse(response, decoder: decoder);
    } on DioException catch (error) {
      throw _mapDioException(error);
    }
  }

  T _decodeResponse<T>(
    Response<dynamic> response, {
    required T Function(Object? data) decoder,
  }) {
    final payload = response.data;
    if (payload is! Map<String, dynamic>) {
      throw AppException('invalid response payload', code: 'INTERNAL_ERROR');
    }

    final envelope = ApiEnvelope<T>.fromJson(payload, decoder);
    if (!envelope.ok) {
      throw AppException(envelope.message, code: envelope.code);
    }
    return envelope.data;
  }

  AppException _mapDioException(DioException error) {
    final responseData = error.response?.data;
    if (responseData is Map<String, dynamic>) {
      final code = responseData['code'] as String?;
      final message = responseData['message'] as String?;
      if (message != null && message.trim().isNotEmpty) {
        return AppException(message, code: code);
      }
    }

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return AppException('网络超时，请稍后重试', code: 'NETWORK_TIMEOUT');
      case DioExceptionType.connectionError:
        return AppException('网络连接失败，请检查服务地址与网络状态', code: 'NETWORK_ERROR');
      case DioExceptionType.badCertificate:
      case DioExceptionType.cancel:
      case DioExceptionType.badResponse:
      case DioExceptionType.unknown:
        return AppException('请求失败，请稍后重试', code: 'REQUEST_FAILED');
    }
  }
}

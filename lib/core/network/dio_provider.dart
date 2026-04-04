import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lexcore/core/constants/app_constants.dart';
import 'package:lexcore/core/network/api_client.dart';
import 'package:lexcore/core/storage/local_storage.dart';

final dioProvider = Provider<Dio>((ref) {
  final localStorage = ref.watch(localStorageProvider);
  final options = BaseOptions(
    baseUrl: AppConstants.baseApiUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    sendTimeout: const Duration(seconds: 10),
    headers: const {'Accept': 'application/json'},
  );

  final dio = Dio(options);
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (requestOptions, handler) {
        final token = localStorage.token;
        if (token != null && token.trim().isNotEmpty) {
          requestOptions.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(requestOptions);
      },
    ),
  );
  return dio;
});

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(ref.watch(dioProvider));
});

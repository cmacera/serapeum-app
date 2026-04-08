import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:serapeum_app/core/auth/auth_provider.dart';
import 'package:serapeum_app/core/constants/api_constants.dart';
import 'package:serapeum_app/core/env/env.dart';
import 'package:serapeum_app/core/network/auth_interceptor.dart';

part 'dio_provider.g.dart';

/// Riverpod provider for the configured [Dio] singleton.
///
/// Base URL is loaded from [Env.apiUrl] (via String.fromEnvironment / --dart-define).
/// Timeouts are defined in [ApiConstants].
@Riverpod(keepAlive: true)
Dio dio(DioRef ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: Env.apiUrl,
      connectTimeout: ApiConstants.connectTimeout,
      receiveTimeout: ApiConstants.receiveTimeout,
      sendTimeout: ApiConstants.sendTimeout,
      contentType: ApiConstants.contentTypeJson,
    ),
  );

  dio.interceptors.add(AuthInterceptor(ref.watch(authServiceProvider), dio));

  if (kDebugMode) {
    // Only log headers/URLs/status — not request or response bodies,
    // to avoid leaking user search queries and API payloads in debug output.
    dio.interceptors.add(
      LogInterceptor(
        requestBody: false,
        responseBody: false,
        logPrint: (o) => debugPrint(o.toString()),
      ),
    );
  }

  return dio;
}

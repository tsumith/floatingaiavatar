import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import '../config/app_config.dart';
import 'network_client.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/app_check_interceptor.dart';

class DioNetworkClient implements NetworkClient {
  static final DioNetworkClient _instance = DioNetworkClient._internal();
  late final Dio _dio;

  factory DioNetworkClient() => _instance;

  DioNetworkClient._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConfig().baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 45),
        headers: const {'Content-Type': 'application/json'},
        validateStatus: (status) =>
            status != null && status >= 200 && status < 300,
      ),
    );

    _dio.interceptors.addAll([
      AuthInterceptor(),
      AppCheckInterceptor(),
      if (kDebugMode) PrettyDioLogger(requestBody: true, responseBody: true),
    ]);
  }

  @override
  Dio get dio => _dio;
}

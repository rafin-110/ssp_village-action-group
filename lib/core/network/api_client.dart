import 'package:dio/dio.dart';

/// Centralized network client for remote API communication.
class ApiClient {
  static final Dio instance = Dio(BaseOptions(
    baseUrl: 'https://api.vagdmp.org/v1', // Placeholder backend URL
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
  ))
    ..interceptors.add(LogInterceptor(responseBody: true, requestBody: true));
}

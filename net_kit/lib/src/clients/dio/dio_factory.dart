import 'package:dio/dio.dart';
import 'package:net_kit/src/models/default_client_config.dart';

class DioFactory {
  static Dio createDio(DefaultClientConfig config) {
    return Dio(
      BaseOptions(
        baseUrl: config.baseUrl ?? '',
        connectTimeout: config.connectionTimeout,
        sendTimeout: config.sendTimeout,
        receiveTimeout: config.receiveTimeout,
        queryParameters: config.queryParameters,
        headers: config.headers,
        followRedirects: config.followRedirects,
        maxRedirects: config.maxRedirects,
      ),
    );
  }
}

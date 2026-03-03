import 'package:dio/dio.dart';

class DioNetworkCallRequest {
  final String pathOrUrl;

  final Object? data;
  final Map<String, dynamic>? queryParams;

  final Options? options;
  final CancelToken? cancelToken;
  final ProgressCallback? onSendProgress;
  final ProgressCallback? onReceiveProgress;

  const DioNetworkCallRequest({
    required this.pathOrUrl,
    this.data,
    this.queryParams,
    this.options,
    this.cancelToken,
    this.onSendProgress,
    this.onReceiveProgress,
  });
}

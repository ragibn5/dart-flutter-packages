import 'package:dio/dio.dart';
import 'package:net_kit/src/models/request_spec.dart';
import 'package:net_kit/src/types/progress_listener.dart';

class DioRequestOptionsBuilder {
  const DioRequestOptionsBuilder();

  RequestOptions build({
    required RequestSpec composedSpec,
    required Object? transformedBody,
    required String? resolvedContentType,
    required CancelToken? cancelToken,
    required ProgressListener? onSendProgress,
    required ProgressListener? onReceiveProgress,
  }) {
    return RequestOptions(
      path: composedSpec.pathOrUrl,
      data: transformedBody,
      method: composedSpec.method.value,
      contentType: resolvedContentType,
      cancelToken: cancelToken,
      sendTimeout: composedSpec.sendTimeout,
      receiveTimeout: composedSpec.receiveTimeout,
      connectTimeout: composedSpec.connectionTimeout,
      queryParameters: composedSpec.queryParameters,
      baseUrl: composedSpec.baseUrl,
      headers: composedSpec.headers,
      followRedirects: composedSpec.followRedirects,
      maxRedirects: composedSpec.maxRedirects,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
      // We may need multiple factors to decide whether the
      // response is an error response, the status-code itself
      // may not be sufficient. We will decide this with the
      // response classifier later on.
      validateStatus: (s) => true,
    );
  }
}

import 'package:dio/dio.dart';
import 'package:net_models/net_models.dart';

/// Maps a [DioException] that carries no server response to an [ApiError].
class DioExceptionTransformer {
  const DioExceptionTransformer();

  ApiError transformApiError(DioException e) {
    return switch (e.type) {
      DioExceptionType.connectionTimeout => const TransportError(
          type: TransportErrorType.CONNECTION_TIMEOUT,
        ),
      DioExceptionType.sendTimeout => const TransportError(
          type: TransportErrorType.SEND_TIMEOUT,
        ),
      DioExceptionType.receiveTimeout => const TransportError(
          type: TransportErrorType.RECEIVE_TIMEOUT,
        ),
      DioExceptionType.connectionError => const TransportError(
          type: TransportErrorType.CONNECTION_ERROR,
        ),
      DioExceptionType.badCertificate => const TransportError(
          type: TransportErrorType.BAD_CERTIFICATE,
        ),
      DioExceptionType.cancel => CancellationError(
          source: '${e.requestOptions.method} ${e.requestOptions.uri}',
          message: e.error?.toString() ?? e.message,
        ),
      // dio adds types in minor releases, so anything else is unexpected.
      _ => UnexpectedError(cause: e.error ?? e, stackTrace: e.stackTrace),
    };
  }
}

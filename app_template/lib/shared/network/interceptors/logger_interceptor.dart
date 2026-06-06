import 'package:app_logger/app_logger.dart';
import 'package:meta/meta.dart';
import 'package:net_kit/net_kit.dart';

class LoggerInterceptor extends NetKitInterceptor {
  @visibleForTesting
  static const TAG = 'LoggerInterceptor';

  final AppLogger _logger;

  LoggerInterceptor(this._logger);

  @override
  Future<RequestInterceptorResult> onRequest(RequestSpec request) async {
    _logger.logInfo(
      tag: TAG,
      message: 'Network request: [${request.uri}]',
      extras: request.toMap(),
    );

    return super.onRequest(request);
  }

  @override
  Future<ResponseInterceptorResult> onResponse(RawResponse response) {
    final request = response.request;
    _logger.logInfo(
      tag: TAG,
      message: 'Network response [${request.uri}]',
      extras: response.toMap(),
    );

    return super.onResponse(response);
  }

  @override
  Future<ErrorInterceptorResult> onError(NetKitException error) {
    final request = error.request;
    _logger.logError(
      tag: TAG,
      message: 'Network error [${request.uri}]',
      error: error.cause,
      stackTrace: error.stackTrace,
      extras: error.toMap(),
    );

    return super.onError(error);
  }
}

import 'package:app_logger/app_logger.dart';
import 'package:dio/dio.dart';
import 'package:meta/meta.dart';

class LoggerInterceptor extends Interceptor {
  @visibleForTesting
  static const TAG = 'LoggerInterceptor';

  final AppLogger _logger;

  LoggerInterceptor(this._logger);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _logger.logInfo(
      tag: TAG,
      message: 'Network request: [${options.uri}]',
      extras: _requestExtras(options),
    );

    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    _logger.logInfo(
      tag: TAG,
      message: 'Network response [${response.requestOptions.uri}]',
      extras: _responseExtras(response),
    );

    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final response = err.response;
    _logger.logError(
      tag: TAG,
      message: 'Network error [${err.requestOptions.uri}]',
      error: err.error ?? err,
      stackTrace: err.stackTrace,
      extras: {
        'type': err.type.name,
        'message': err.message,
        'request': _requestExtras(err.requestOptions),
        if (response != null) 'response': _responseExtras(response),
      },
    );

    handler.next(err);
  }

  Map<String, dynamic> _requestExtras(RequestOptions options) {
    return {
      'method': options.method,
      'uri': '${options.uri}',
      'headers': options.headers,
      'data': options.data,
    };
  }

  Map<String, dynamic> _responseExtras(Response<dynamic> response) {
    return {
      'statusCode': response.statusCode,
      'headers': response.headers.map,
      'data': response.data,
    };
  }
}

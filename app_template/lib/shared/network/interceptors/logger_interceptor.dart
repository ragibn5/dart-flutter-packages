import 'package:app_template/shared/logger/app_logger.dart';
import 'package:dio/dio.dart';
import 'package:meta/meta.dart';
import 'package:string_extensions/string_extensions.dart';

class LoggerInterceptor extends Interceptor {
  @visibleForTesting
  static const TAG = 'LoggerInterceptor';

  final AppLogger _logger;

  LoggerInterceptor(this._logger);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    _logger.logInfo(
      tag: TAG,
      message: 'Network request [${options.baseUrl}${options.path}]',
      extras: {
        'request_body': options.data,
        'request_header': options.headers,
        'query_parameters': options.queryParameters,
      },
    );

    handler.next(options);
  }

  @override
  Future<void> onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) async {
    final requestOptions = response.requestOptions;
    final absPath = '${requestOptions.baseUrl}${requestOptions.path}';
    _logger.logInfo(
      tag: TAG,
      message: 'Network response [$absPath]',
      extras: {
        'response_body': response.data,
        'response_header': response.headers,
      },
    );

    handler.next(response);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final requestOptions = err.requestOptions;
    final absPath = '${requestOptions.baseUrl}${requestOptions.path}';
    _logger.logError(
      tag: TAG,
      message:
          'Network error [${absPath.isEmptyOrBlank ? "Path N/A" : absPath}]',
      stackTrace: err.stackTrace,
      extras: {
        'request_method': err.requestOptions.method,
        'error_type': err.type.name,
        'error_message': err.message ?? '[N/A]',
        'request_body': err.requestOptions.data ?? '[N/A]',
        'request_header': err.requestOptions.headers,
        'request_params': err.requestOptions.queryParameters,
        'response_code': err.response?.statusCode,
        'response_body': err.response?.data ?? '[N/A]',
        'response_header': err.response?.headers ?? '[N/A]',
      },
    );

    handler.next(err);
  }
}

import 'package:dio/dio.dart';
import 'package:net_kit/src/enums/transport_error_type.dart';
import 'package:net_kit/src/models/net_kit_exception.dart';

class DioExceptionMapper {
  const DioExceptionMapper();

  NetKitException mapException(Object exception, {StackTrace? stackTrace}) {
    if (exception is! DioException) {
      return UnexpectedException(
        'Received unknown exception',
        cause: exception,
        stackTrace: stackTrace,
      );
    }

    return switch (exception.type) {
      DioExceptionType.connectionTimeout => TransportException(
          TransportErrorType.CONNECTION_TIMEOUT,
          cause: exception.error,
          stackTrace: exception.stackTrace,
        ),
      DioExceptionType.sendTimeout => TransportException(
          TransportErrorType.SEND_TIMEOUT,
          cause: exception.error,
          stackTrace: exception.stackTrace,
        ),
      DioExceptionType.receiveTimeout => TransportException(
          TransportErrorType.RECEIVE_TIMEOUT,
          cause: exception.error,
          stackTrace: exception.stackTrace,
        ),
      DioExceptionType.badCertificate => TransportException(
          TransportErrorType.BAD_CERTIFICATE,
          cause: exception.error,
          stackTrace: exception.stackTrace,
        ),
      DioExceptionType.connectionError => TransportException(
          TransportErrorType.CONNECTION_ERROR,
          cause: exception.error,
          stackTrace: exception.stackTrace,
        ),
      DioExceptionType.cancel => CancellationException(
          cause: exception.error,
          stackTrace: exception.stackTrace,
        ),
      _ => UnexpectedException(
          // ignore: lines_longer_than_80_chars
          'Client threw unknown exception (${exception.type.name}): ${exception.message}',
          cause: exception.error,
          stackTrace: exception.stackTrace,
        ),
    };
  }
}

import 'package:dio/dio.dart';
import 'package:net_kit/src/enums/network_exception_type.dart';
import 'package:net_kit/src/models/net_kit_exception.dart';
import 'package:net_kit/src/services/codec/net_kit_response_decoder.dart';

abstract interface class ClientExceptionMapper {
  NetKitException mapException<E>(
    Object exception, {
    StackTrace? stackTrace,
    required E Function(dynamic) errorDecoder,
  });
}

class ClientExceptionMapperImpl implements ClientExceptionMapper {
  final NetKitResponseDecoder _errorResponseDecoder;

  const ClientExceptionMapperImpl(this._errorResponseDecoder);

  @override
  NetKitException mapException<E>(
    Object exception, {
    StackTrace? stackTrace,
    required E Function(dynamic) errorDecoder,
  }) {
    if (exception is! DioException) {
      return UnexpectedException(
        'Received unknown exception',
        cause: exception,
        stackTrace: stackTrace,
      );
    }

    return switch (exception.type) {
      DioExceptionType.connectionTimeout => NetworkException(
          NetworkExceptionType.CONNECTION_TIMEOUT,
          cause: exception.error,
          stackTrace: exception.stackTrace,
        ),
      DioExceptionType.sendTimeout => NetworkException(
          NetworkExceptionType.SEND_TIMEOUT,
          cause: exception.error,
          stackTrace: exception.stackTrace,
        ),
      DioExceptionType.receiveTimeout => NetworkException(
          NetworkExceptionType.RECEIVE_TIMEOUT,
          cause: exception.error,
          stackTrace: exception.stackTrace,
        ),
      DioExceptionType.badCertificate => NetworkException(
          NetworkExceptionType.BAD_CERTIFICATE,
          cause: exception.error,
          stackTrace: exception.stackTrace,
        ),
      DioExceptionType.connectionError => NetworkException(
          NetworkExceptionType.CONNECTION_ERROR,
          cause: exception.error,
          stackTrace: exception.stackTrace,
        ),
      DioExceptionType.cancel => CancellationException(
          cause: exception.error,
          stackTrace: exception.stackTrace,
        ),
      DioExceptionType.badResponse => _decodeErrorResponse(
          response: exception.response,
          errorResponseDecoder: errorDecoder,
          cause: exception.error,
          stackTrace: exception.stackTrace,
        ),
      DioExceptionType.unknown => UnexpectedException(
          // ignore: lines_longer_than_80_chars
          'Client threw unknown exception (${exception.type.name}): ${exception.message}',
          cause: exception.error,
          stackTrace: exception.stackTrace,
        ),
    };
  }

  /// Decodes an error response, wrapping decode failures.
  NetKitException _decodeErrorResponse<E>({
    required Response<dynamic>? response,
    required E Function(dynamic) errorResponseDecoder,
    required Object? cause,
    required StackTrace? stackTrace,
  }) {
    if (response == null) {
      return UnexpectedException(
        'Expected a response to be non-null',
        cause: cause,
        stackTrace: stackTrace,
      );
    }

    return _errorResponseDecoder
        .decode(response.data, errorResponseDecoder)
        .fold(
          onError: (pe) => pe,
          onSuccess: (e) =>
              DomainException(e, cause: cause, stackTrace: stackTrace),
        );
  }
}

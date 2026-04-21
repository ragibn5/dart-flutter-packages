import 'package:dio/dio.dart';
import 'package:net_kit/src/enums/network_exception_type.dart';
import 'package:net_kit/src/models/decoded_error_response.dart';
import 'package:net_kit/src/models/net_kit_exception.dart';
import 'package:net_kit/src/models/result.dart';
import 'package:net_kit/src/services/codec/net_kit_response_decoder.dart';
import 'package:net_kit/src/services/mappers/client_exception_mapper.dart';

class ClientExceptionMapperImpl implements ClientExceptionMapper {
  final int _defaultResponseCode;
  final NetKitResponseDecoder _errorResponseDecoder;

  const ClientExceptionMapperImpl(
    this._defaultResponseCode,
    this._errorResponseDecoder,
  );

  @override
  Result<NetKitException, DecodedErrorResponse<DomainErrorType>>
      mapException<DomainErrorType>(
    Object exception, {
    StackTrace? stackTrace,
    required DomainErrorType Function(dynamic) errorDecoder,
  }) {
    if (exception is! DioException) {
      return Result.error(
        UnexpectedException(
          'Received unknown exception',
          cause: exception,
          stackTrace: stackTrace,
        ),
      );
    }

    return switch (exception.type) {
      DioExceptionType.connectionTimeout => Result.error(
          NetworkException(
            NetworkExceptionType.CONNECTION_TIMEOUT,
            cause: exception.error,
            stackTrace: exception.stackTrace,
          ),
        ),
      DioExceptionType.sendTimeout => Result.error(
          NetworkException(
            NetworkExceptionType.SEND_TIMEOUT,
            cause: exception.error,
            stackTrace: exception.stackTrace,
          ),
        ),
      DioExceptionType.receiveTimeout => Result.error(
          NetworkException(
            NetworkExceptionType.RECEIVE_TIMEOUT,
            cause: exception.error,
            stackTrace: exception.stackTrace,
          ),
        ),
      DioExceptionType.badCertificate => Result.error(
          NetworkException(
            NetworkExceptionType.BAD_CERTIFICATE,
            cause: exception.error,
            stackTrace: exception.stackTrace,
          ),
        ),
      DioExceptionType.connectionError => Result.error(
          NetworkException(
            NetworkExceptionType.CONNECTION_ERROR,
            cause: exception.error,
            stackTrace: exception.stackTrace,
          ),
        ),
      DioExceptionType.cancel => Result.error(
          CancellationException(
            cause: exception.error,
            stackTrace: exception.stackTrace,
          ),
        ),
      DioExceptionType.unknown => Result.error(
          UnexpectedException(
            // ignore: lines_longer_than_80_chars
            'Client threw unknown exception (${exception.type.name}): ${exception.message}',
            cause: exception.error,
            stackTrace: exception.stackTrace,
          ),
        ),
      DioExceptionType.badResponse => _decodeErrorResponse(
          response: exception.response,
          errorResponseDecoder: errorDecoder,
        ),
    };
  }

  /// Decodes an error response, wrapping decode failures.
  Result<NetKitException, DecodedErrorResponse<E>> _decodeErrorResponse<E>({
    required Response<dynamic>? response,
    required E Function(dynamic) errorResponseDecoder,
  }) {
    if (response == null) {
      return Result.error(
        const UnexpectedException('Expected a response to be non-null'),
      );
    }

    return _errorResponseDecoder
        .decode(response.data, errorResponseDecoder)
        .fold(
          onError: Result.error,
          onSuccess: (e) => Result.success(
            DecodedErrorResponse(
              statusCode: response.statusCode ?? _defaultResponseCode,
              error: e,
              headers: response.headers.map,
            ),
          ),
        );
  }
}

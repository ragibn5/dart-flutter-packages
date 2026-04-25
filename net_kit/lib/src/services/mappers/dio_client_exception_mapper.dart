import 'package:dio/dio.dart';
import 'package:net_kit/src/enums/transport_error_type.dart';
import 'package:net_kit/src/models/error_response_data.dart';
import 'package:net_kit/src/models/net_kit_exception.dart';
import 'package:net_kit/src/models/result.dart';
import 'package:net_kit/src/services/codec/request_data_codec.dart';
import 'package:net_kit/src/services/mappers/client_exception_mapper.dart';
import 'package:net_kit/src/services/transformers/error_response_data_transformer.dart';

class DioClientExceptionMapper implements ClientExceptionMapper {
  final int _defaultResponseCode;
  final ErrorResponseDataTransformer _errorResponseDataTransformer;

  const DioClientExceptionMapper(
    this._defaultResponseCode,
    this._errorResponseDataTransformer,
  );

  @override
  Result<NetKitException, ErrorResponseData<DomainErrorType>>
      mapException<DomainErrorType>(
    Object exception, {
    StackTrace? stackTrace,
    required ErrorResponseDataDecoder<DomainErrorType> errorResponseDataDecoder,
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
          TransportException(
            TransportErrorType.CONNECTION_TIMEOUT,
            cause: exception.error,
            stackTrace: exception.stackTrace,
          ),
        ),
      DioExceptionType.sendTimeout => Result.error(
          TransportException(
            TransportErrorType.SEND_TIMEOUT,
            cause: exception.error,
            stackTrace: exception.stackTrace,
          ),
        ),
      DioExceptionType.receiveTimeout => Result.error(
          TransportException(
            TransportErrorType.RECEIVE_TIMEOUT,
            cause: exception.error,
            stackTrace: exception.stackTrace,
          ),
        ),
      DioExceptionType.badCertificate => Result.error(
          TransportException(
            TransportErrorType.BAD_CERTIFICATE,
            cause: exception.error,
            stackTrace: exception.stackTrace,
          ),
        ),
      DioExceptionType.connectionError => Result.error(
          TransportException(
            TransportErrorType.CONNECTION_ERROR,
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
          errorResponseDataDecoder: errorResponseDataDecoder,
        ),
    };
  }

  /// Decodes an error response, wrapping decode failures.
  Result<NetKitException, ErrorResponseData<E>> _decodeErrorResponse<E>({
    required Response<dynamic>? response,
    required ErrorResponseDataDecoder<E> errorResponseDataDecoder,
  }) {
    if (response == null) {
      return Result.error(
        const UnexpectedException('Expected a response to be non-null'),
      );
    }

    return _errorResponseDataTransformer
        .transform(response.data, errorResponseDataDecoder)
        .fold(
          onError: Result.error,
          onSuccess: (e) => Result.success(
            ErrorResponseData(
              statusCode: response.statusCode ?? _defaultResponseCode,
              error: e,
              headers: response.headers.map,
            ),
          ),
        );
  }
}

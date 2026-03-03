import 'package:app_template/core/infrastructure/network/error_mappers/api_error_mapper.dart';
import 'package:app_template/core/models/api_error.dart';
import 'package:dio/dio.dart';
import 'package:meta/meta.dart';

abstract class DioFeatureApiErrorMapper<FeatureErrorType>
    implements ApiErrorMapper<ApiError<FeatureErrorType>> {
  /// This method is designed to map errors sent from api client to [ApiError].
  @override
  ApiError<FeatureErrorType> mapError(
    Object exception,
    StackTrace? stackTrace,
  ) {
    if (exception is DioException) {
      final response = exception.response;
      return response != null
          ? mapServerError(response.statusCode, response.data)
          : _mapLocalError(exception);
    } else {
      return ApiError.fromAppError(
        IllegalStateError(
          message: 'Error from api client.',
          exception: exception,
          stackTrace: stackTrace,
        ),
      );
    }
  }

  /// Tries to map a local error object from the exception.
  ApiError<FeatureErrorType> _mapLocalError(DioException exception) {
    return switch (exception.type) {
      DioExceptionType.connectionTimeout => ApiError.fromNetworkError(
        ConnectionTimeout(
          message: 'Connection timeout in central api error converter.',
          exception: exception.error,
          stackTrace: exception.stackTrace,
        ),
      ),
      DioExceptionType.sendTimeout => ApiError.fromNetworkError(
        SendTimeout(
          message: 'Send timeout in central api error converter.',
          exception: exception.error,
          stackTrace: exception.stackTrace,
        ),
      ),
      DioExceptionType.receiveTimeout => ApiError.fromNetworkError(
        ReceiveTimeout(
          message: 'Receive timeout in central api error converter.',
          exception: exception.error,
          stackTrace: exception.stackTrace,
        ),
      ),
      DioExceptionType.connectionError => ApiError.fromNetworkError(
        ConnectionError(
          message: 'Connection error in central api error converter.',
          exception: exception.error,
          stackTrace: exception.stackTrace,
        ),
      ),
      DioExceptionType.badCertificate => ApiError.fromNetworkError(
        BadCertificate(
          message: 'Bad certificate error in central api error converter.',
          exception: exception.error,
          stackTrace: exception.stackTrace,
        ),
      ),
      DioExceptionType.badResponse => ApiError.fromNetworkError(
        BadResponse(
          message: 'Bad response error in central api error converter.',
          exception: exception.error,
          stackTrace: exception.stackTrace,
        ),
      ),
      DioExceptionType.unknown => ApiError.fromAppError(
        IllegalStateError(
          message: 'Unknown error in central api error converter.',
          exception: exception.error,
          stackTrace: exception.stackTrace,
        ),
      ),
      DioExceptionType.cancel => _mapCancelledError(exception),
    };
  }

  /// Map cancellation errors from the exception.
  ApiError<FeatureErrorType> _mapCancelledError(DioException exception) {
    final reason = exception.error;
    final stackTrace = exception.stackTrace;
    if (reason == null || reason is! Cancelled) {
      return ApiError.fromAppError(
        IllegalStateError(
          message: 'Operation cancelled.',
          exception: reason,
          stackTrace: stackTrace,
        ),
      );
    }

    return ApiError.fromAppError(reason);
  }

  /// Map server errors from the error response.
  ///
  /// Other type of errors such as network errors and application errors
  /// are automatically mapped. But different servers can follow different
  /// approaches and error models, so it is better to let you do that instead.
  @visibleForOverriding
  ApiError<FeatureErrorType> mapServerError(
    int? statusCode,
    dynamic errorResponseBody,
  );
}

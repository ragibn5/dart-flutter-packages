import 'package:equatable/equatable.dart';

enum _ApiErrorType { app, network, server }

class ApiError<FeatureErrorType> extends Equatable {
  final _ApiErrorType _type;

  final AppError? _appError;
  final NetworkError? _networkError;
  final FeatureErrorType? _serverError;

  const ApiError._({
    required _ApiErrorType type,
    AppError? appError,
    NetworkError? networkError,
    FeatureErrorType? serverError,
  }) : _type = type,
       _appError = appError,
       _networkError = networkError,
       _serverError = serverError;

  factory ApiError.fromAppError(AppError error) {
    return ApiError._(type: _ApiErrorType.app, appError: error);
  }

  factory ApiError.fromNetworkError(NetworkError error) {
    return ApiError._(type: _ApiErrorType.network, networkError: error);
  }

  factory ApiError.fromServerError(FeatureErrorType error) {
    return ApiError._(type: _ApiErrorType.server, serverError: error);
  }

  T fold<T>(
    T Function(AppError error) onAppError,
    T Function(NetworkError error) onNetworkError,
    T Function(FeatureErrorType error) onServerError,
  ) {
    return switch (_type) {
      _ApiErrorType.app => onAppError(_appError!),
      _ApiErrorType.network => onNetworkError(_networkError!),
      _ApiErrorType.server => onServerError(_serverError as FeatureErrorType),
    };
  }

  bool get isAppError => _type == _ApiErrorType.app;

  bool get isNetworkError => _type == _ApiErrorType.network;

  bool get isServerError => _type == _ApiErrorType.server;

  AppError? get appErrorOrNull => _appError;

  NetworkError? get networkErrorOrNull => _networkError;

  FeatureErrorType? get serverErrorOrNull => _serverError;

  @override
  List<Object?> get props => [_type, _appError, _networkError, _serverError];
}

//
// App Error Types
//

sealed class AppError extends Equatable {
  final String message;
  final Object? exception;
  final StackTrace? stackTrace;

  const AppError({required this.message, this.exception, this.stackTrace});
}

final class IllegalStateError extends AppError {
  const IllegalStateError({
    required super.message,
    super.exception,
    super.stackTrace,
  });

  @override
  List<Object?> get props => [message, exception, stackTrace];
}

sealed class Cancelled extends AppError {
  const Cancelled({required super.message, super.exception, super.stackTrace});
}

final class CancelledDueToAuthDataUnavailability extends Cancelled {
  const CancelledDueToAuthDataUnavailability({
    required super.message,
    super.exception,
    super.stackTrace,
  });

  @override
  List<Object?> get props => [message, exception, stackTrace];
}

final class CancelledDueToAuthDataRefreshFailure extends Cancelled {
  const CancelledDueToAuthDataRefreshFailure({
    required super.message,
    super.exception,
    super.stackTrace,
  });

  @override
  List<Object?> get props => [message, exception, stackTrace];
}

//
// Network Error Types
//

sealed class NetworkError extends Equatable {
  final String message;
  final Object? exception;
  final StackTrace? stackTrace;

  const NetworkError({required this.message, this.exception, this.stackTrace});
}

final class ConnectionTimeout extends NetworkError {
  const ConnectionTimeout({
    required super.message,
    super.exception,
    super.stackTrace,
  });

  @override
  List<Object?> get props => [message, exception, stackTrace];
}

final class SendTimeout extends NetworkError {
  const SendTimeout({
    required super.message,
    super.exception,
    super.stackTrace,
  });

  @override
  List<Object?> get props => [message, exception, stackTrace];
}

final class ReceiveTimeout extends NetworkError {
  const ReceiveTimeout({
    required super.message,
    super.exception,
    super.stackTrace,
  });

  @override
  List<Object?> get props => [message, exception, stackTrace];
}

final class ConnectionError extends NetworkError {
  const ConnectionError({
    required super.message,
    super.exception,
    super.stackTrace,
  });

  @override
  List<Object?> get props => [message, exception, stackTrace];
}

final class BadCertificate extends NetworkError {
  const BadCertificate({
    required super.message,
    super.exception,
    super.stackTrace,
  });

  @override
  List<Object?> get props => [message, exception, stackTrace];
}

final class BadResponse extends NetworkError {
  const BadResponse({
    required super.message,
    super.exception,
    super.stackTrace,
  });

  @override
  List<Object?> get props => [message, exception, stackTrace];
}

//
// Server error
//

final class ServerError<T> extends Equatable {
  final int statusCode;
  final T errorResponse;

  const ServerError({required this.statusCode, required this.errorResponse});

  @override
  List<Object?> get props => [statusCode, errorResponse];
}

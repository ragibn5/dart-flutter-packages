import 'package:net_kit/src/clients/net_client.dart';
import 'package:net_kit/src/enums/network_exception_type.dart';
import 'package:net_kit/src/enums/parse_target_type.dart';

/// The base exception type that [NetClient.execute] returns when it
/// encounters any error.
///
/// See its subtypes for more details.
sealed class NetClientException {
  /// The cause of the exception.
  final Object? cause;

  /// The stack trace of the exception.
  final StackTrace? stackTrace;

  const NetClientException(this.cause, this.stackTrace);
}

/// A network failure.
final class NetworkException extends NetClientException {
  /// The type of network failure.
  final NetworkExceptionType type;

  const NetworkException(
    this.type, {
    Object? cause,
    StackTrace? stackTrace,
  }) : super(cause, stackTrace);

  @override
  String toString() {
    // ignore: lines_longer_than_80_chars
    return 'NetworkException{type: $type, cause: $cause, stackTrace: $stackTrace}';
  }
}

/// A failure indicating encode/decode data (request, response, error response etc.).
final class ParseException extends NetClientException {
  /// The type of target that we were failed to encode/decode.
  final ParseTargetType targetType;

  /// The data data that failed to decode.
  final dynamic data;

  const ParseException({
    required this.targetType,
    required this.data,
    Object? cause,
    StackTrace? stackTrace,
  }) : super(cause, stackTrace);

  @override
  String toString() {
    // ignore: lines_longer_than_80_chars
    return 'ParseException {targetType: $targetType, data: $data, cause: $cause, stackTrace: $stackTrace}';
  }
}

/// A failure indicating explicit request cancellation.
final class CancellationException extends NetClientException {
  const CancellationException({
    Object? cause,
    StackTrace? stackTrace,
  }) : super(cause, stackTrace);

  @override
  String toString() {
    // ignore: lines_longer_than_80_chars
    return 'CancellationException {cause: $cause, stackTrace: $stackTrace}';
  }
}

/// Generic failure indicating an unexpected exception from the client.
final class UnexpectedException extends NetClientException {
  final String message;

  const UnexpectedException(
    this.message, {
    Object? cause,
    StackTrace? stackTrace,
  }) : super(cause, stackTrace);

  @override
  String toString() {
    // ignore: lines_longer_than_80_chars
    return 'UnexpectedException{message: $message, cause: $cause, stackTrace: $stackTrace}';
  }
}

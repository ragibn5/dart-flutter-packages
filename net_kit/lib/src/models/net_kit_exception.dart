import 'package:net_kit/src/clients/net_client.dart';
import 'package:net_kit/src/enums/transport_error_type.dart';

/// The base exception returned by [NetClient] when it encounters any error.
///
/// See its subtypes for more details.
sealed class NetKitException {
  /// The underlying cause of this exception.
  ///
  /// **Warning**:
  /// This value can be transport or runtime specific, and may come
  /// from the underlying HTTP client. This is not a part of the stable
  /// API and should never be used for control flow.
  final Object? cause;

  /// Stack trace associated with this failure.
  ///
  /// **Warning**:
  /// This value can be transport or runtime specific, and may come
  /// from the underlying HTTP client. This is not a part of the stable
  /// API and should never be used for control flow.
  final StackTrace? stackTrace;

  const NetKitException(this.cause, this.stackTrace);
}

/// A network failure.
final class TransportException extends NetKitException {
  /// The type of network failure.
  final TransportErrorType type;

  const TransportException(
    this.type, {
    Object? cause,
    StackTrace? stackTrace,
  }) : super(cause, stackTrace);

  @override
  String toString() {
    // ignore: lines_longer_than_80_chars
    return 'TransportException {type: $type, cause: $cause, stackTrace: $stackTrace}';
  }
}

/// A failure indicating explicit request cancellation.
final class CancellationException extends NetKitException {
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
final class UnexpectedException extends NetKitException {
  /// Summary of the unexpected failure.
  ///
  /// This should not be used for control flow.
  final String message;

  const UnexpectedException(
    this.message, {
    Object? cause,
    StackTrace? stackTrace,
  }) : super(cause, stackTrace);

  @override
  String toString() {
    // ignore: lines_longer_than_80_chars
    return 'UnexpectedException {message: $message, cause: $cause, stackTrace: $stackTrace}';
  }
}

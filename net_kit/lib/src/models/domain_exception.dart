/// A failure indicating an domain specific error returned by the server.
final class DomainException<E> {
  /// The decoded, domain-typed error from the server.
  final E error;

  /// The cause of the exception.
  final Object? cause;

  /// The stack trace of the exception.
  final StackTrace? stackTrace;

  const DomainException(
    this.error, {
    this.cause,
    this.stackTrace,
  });

  @override
  String toString() {
    // ignore: lines_longer_than_80_chars
    return 'DomainException{error: $error, cause: $cause, stackTrace: $stackTrace}';
  }
}

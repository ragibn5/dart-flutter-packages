/// Why the interceptor gave up on a request.
enum AuthRecoveryFailure {
  /// No auth data was available to authorize the request.
  authDataUnavailable,

  /// The auth data could not be refreshed.
  refreshFailed,

  /// The request failed again when retried with the auth data.
  retryFailed,
}

/// The `error` of the cancelled `DioException` the interceptor rejects a
/// request with, so an app can tell a lost session apart from other
/// cancellations.
class AuthRecoveryException implements Exception {
  final AuthRecoveryFailure reason;

  /// What the retry failed with, for [AuthRecoveryFailure.retryFailed].
  final Object? cause;

  const AuthRecoveryException(this.reason, {this.cause});

  @override
  String toString() => 'AuthRecoveryException: ${reason.name}'
      '${cause == null ? '' : ', caused by: $cause'}';
}

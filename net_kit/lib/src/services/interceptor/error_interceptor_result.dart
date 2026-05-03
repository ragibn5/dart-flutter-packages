import 'package:net_kit/src/models/net_kit_exception.dart';
import 'package:net_kit/src/models/response_context.dart';

sealed class ErrorInterceptorResult {
  const ErrorInterceptorResult();
}

/// Pass through or replace the error, continuing to the next interceptor.
final class ContinueWithError extends ErrorInterceptorResult {
  final NetKitException error;

  const ContinueWithError(this.error);
}

/// Short-circuit with this error, skipping remaining interceptors.
final class RejectError extends ErrorInterceptorResult {
  final NetKitException error;

  const RejectError(this.error);
}

/// Recover from the error and treat it as a successful response.
final class RecoverError extends ErrorInterceptorResult {
  final ResponseContext response;

  const RecoverError(this.response);
}

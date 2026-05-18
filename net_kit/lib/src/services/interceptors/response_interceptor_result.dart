import 'package:net_kit/src/models/net_kit_exception.dart';
import 'package:net_kit/src/models/raw_response.dart';

sealed class ResponseInterceptorResult {
  const ResponseInterceptorResult();
}

/// Continues the interceptor chain with the (possibly modified) response.
final class ContinueWithResponse extends ResponseInterceptorResult {
  final RawResponse response;

  const ContinueWithResponse(this.response);
}

/// Short-circuits the chain, returning an error instead of the response.
/// Remaining interceptors are skipped.
final class ShortResponseWithError extends ResponseInterceptorResult {
  final NetKitException error;

  const ShortResponseWithError(this.error);
}

/// Short-circuits the chain, returning this response immediately.
/// Remaining interceptors are skipped.
final class ShortResponseWithFinalResponse extends ResponseInterceptorResult {
  final RawResponse response;

  const ShortResponseWithFinalResponse(this.response);
}

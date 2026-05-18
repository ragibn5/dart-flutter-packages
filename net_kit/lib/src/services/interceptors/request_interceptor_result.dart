import 'package:net_kit/src/models/net_kit_exception.dart';
import 'package:net_kit/src/models/raw_response.dart';
import 'package:net_kit/src/models/request_spec.dart';

sealed class RequestInterceptorResult {
  const RequestInterceptorResult();
}

/// Continues the interceptor chain with the (possibly modified) request.
final class ContinueWithRequest extends RequestInterceptorResult {
  final RequestSpec request;

  const ContinueWithRequest(this.request);
}

/// Short-circuits the chain, returning an error without reaching the transport.
/// Remaining interceptors are skipped.
final class ShortRequestWithError extends RequestInterceptorResult {
  final NetKitException error;

  const ShortRequestWithError(this.error);
}

/// Short-circuits the chain, returning a synthetic response without reaching
/// the transport. Remaining interceptors are skipped.
final class ShortRequestWithResponse extends RequestInterceptorResult {
  final RawResponse response;

  const ShortRequestWithResponse(this.response);
}

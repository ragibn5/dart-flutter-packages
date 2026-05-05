import 'package:net_kit/src/models/net_kit_exception.dart';
import 'package:net_kit/src/models/raw_response.dart';

sealed class ResponseInterceptorResult {
  const ResponseInterceptorResult();
}

/// Continue the pipeline with the (possibly modified) response.
final class ContinueWithResponse extends ResponseInterceptorResult {
  final RawResponse response;

  const ContinueWithResponse(this.response);
}

/// Reject the response and return an error instead.
final class RejectResponse extends ResponseInterceptorResult {
  final NetKitException error;

  const RejectResponse(this.error);
}

/// Short-circuit with this response, skipping remaining interceptors.
final class ResolveResponse extends ResponseInterceptorResult {
  final RawResponse response;

  const ResolveResponse(this.response);
}

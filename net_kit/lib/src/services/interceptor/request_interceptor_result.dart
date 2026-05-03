import 'package:net_kit/src/models/net_kit_exception.dart';
import 'package:net_kit/src/models/request_spec.dart';
import 'package:net_kit/src/models/response_context.dart';

sealed class RequestInterceptorResult {
  const RequestInterceptorResult();
}

/// Continue the pipeline with the (possibly modified) request.
final class ContinueWithRequest extends RequestInterceptorResult {
  final RequestSpec request;

  const ContinueWithRequest(this.request);
}

/// Reject the request and return an error without reaching the server.
final class RejectRequest extends RequestInterceptorResult {
  final NetKitException error;

  const RejectRequest(this.error);
}

/// Short-circuit with a fake response, skipping the transport entirely.
final class ResolveRequest extends RequestInterceptorResult {
  final ResponseContext response;

  const ResolveRequest(this.response);
}

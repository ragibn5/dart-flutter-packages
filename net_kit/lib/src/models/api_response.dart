import 'package:net_kit/src/models/request_spec.dart';
import 'package:net_kit/src/models/result.dart';

class ApiResponse<Req, Res, Err> {
  /// The status code from the server side.
  final int statusCode;

  /// The response body, or error.
  final Result<Err, Res> data;

  /// The response headers.
  final Map<String, List<String>> headers;

  /// The request spec that was sent to the server.
  final RequestSpec<Req> requestSpec;

  /// Low-level transport/client cause associated with this response.
  ///
  /// This is typically only populated when a client exception produced a
  /// decodable error response.
  final Object? cause;

  /// Stack trace associated with [cause].
  ///
  /// This is typically only populated when a client exception produced a
  /// decodable error response.
  final StackTrace? stackTrace;

  ApiResponse({
    required this.statusCode,
    required this.data,
    required this.headers,
    required this.requestSpec,
    this.cause,
    this.stackTrace,
  });

  /// Whether transport diagnostics are available for this response.
  bool get hasDiagnostics => cause != null || stackTrace != null;

  bool isError() => data.isError;

  Err? errorOrNull() => data.errorOrNull;

  Res? resultOrNull() => data.resultOrNull;
}

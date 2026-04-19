import 'package:net_kit/net_kit.dart';

class ApiResponse<Req, Res, Err> {
  /// The status code from the server side.
  final int statusCode;

  /// The response body, or error.
  final Result<Err, Res> data;

  /// The response headers.
  final Map<String, List<String>> headers;

  /// The request spec that was sent to the server.
  final RequestSpec<Req> requestSpec;

  ApiResponse({
    required this.statusCode,
    required this.data,
    required this.headers,
    required this.requestSpec,
  });

  bool isError() => data.isError;

  Err? errorOrNull() => data.errorOrNull;

  Res? resultOrNull() => data.resultOrNull;
}

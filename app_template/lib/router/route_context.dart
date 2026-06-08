class RouteContext {
  final Map<String, String> pathParameters;
  final Map<String, Object?> queryParameters;
  final Object? extra;

  const RouteContext({
    this.pathParameters = const {},
    this.queryParameters = const {},
    this.extra,
  });
}

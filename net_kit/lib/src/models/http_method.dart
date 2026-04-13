/// Represents the HTTP method used in a request.
enum HttpMethod {
  GET('GET'),
  POST('POST'),
  PUT('PUT'),
  PATCH('PATCH'),
  DELETE('DELETE');

  /// The raw string value passed to Dio.
  final String value;

  const HttpMethod(this.value);
}

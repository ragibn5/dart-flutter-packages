/// A codec and response decoding.
abstract interface class ResponseDataCodec<Res, Err>
    implements ResponseDataDecoder<Res>, ErrorResponseDataDecoder<Err> {}

/// Decodes data from the HTTP client's response.
abstract interface class ResponseDataDecoder<Res> {
  /// Decodes the raw response data into [Res].
  ///
  /// [raw] is the raw response data from the HTTP client — typically a
  /// `Map<String, dynamic>`, `List<dynamic>`, or a primitive, depending on
  /// the client configuration and the server response.
  Res decodeData(dynamic raw);
}

/// Decodes data from the HTTP client's error response.
abstract interface class ErrorResponseDataDecoder<Err> {
  /// Decodes the raw error response data into [Err].
  ///
  /// [raw] is the raw response data from the HTTP client on an error response.
  Err decodeErrorData(dynamic raw);
}

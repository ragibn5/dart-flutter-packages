abstract interface class RequestCodec<Req, Res, Err> {
  /// Encodes [body] into a form that the HTTP client can send over the wire.
  ///
  /// The return value is passed directly as the request `data`.
  /// Return `null` to send no body.
  ///
  /// Common implementations:
  /// - JSON: `return body.toJson();`
  /// - Raw string: `return body.toString();`
  ///
  /// This method is only called when [body] is non-null.
  dynamic encodeBody(Req body);

  /// Decodes the raw response data into [Res].
  ///
  /// [raw] is the raw response data from the HTTP client — typically a
  /// `Map<String, dynamic>`, `List<dynamic>`, or a primitive, depending on
  /// the client configuration and the server response.
  Res decodeResponse(dynamic raw);

  /// Decodes the raw error response data into [Err].
  ///
  /// [raw] is the raw response data from the HTTP client on an error response.
  Err decodeError(dynamic raw);
}

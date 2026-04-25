/// A codec for requests and responses.
abstract interface class RequestDataCodec<Req, Res, Err>
    implements
        RequestDataEncoder<Req>,
        ResponseDataDecoder<Res>,
        ErrorResponseDataDecoder<Err> {}

/// Encodes data into a form that the HTTP client can send over the wire.
abstract interface class RequestDataEncoder<Req> {
  /// Encodes [data] into a form that the HTTP client can send over the wire.
  ///
  /// The return value is passed directly as the request `data`.
  ///
  /// Common implementations:
  /// - JSON: `return data.toJson();`
  /// - Raw string: `return data.toString();`
  ///
  /// This method is only called when [data] is non-null.
  dynamic encodeRequestData(Req data);
}

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

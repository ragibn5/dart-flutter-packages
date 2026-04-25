abstract interface class RequestCodec<Req, Res, Err>
    implements
        RequestEncoder<Req>,
        ResponseDecoder<Res>,
        ErrorResponseDecoder<Err> {}

abstract interface class RequestEncoder<Req> {
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

abstract interface class ResponseDecoder<Res> {
  /// Decodes the raw response data into [Res].
  ///
  /// [raw] is the raw response data from the HTTP client — typically a
  /// `Map<String, dynamic>`, `List<dynamic>`, or a primitive, depending on
  /// the client configuration and the server response.
  Res decodeSuccessfulResponse(dynamic raw);
}

abstract interface class ErrorResponseDecoder<Err> {
  /// Decodes the raw error response data into [Err].
  ///
  /// [raw] is the raw response data from the HTTP client on an error response.
  Err decodeErrorResponse(dynamic raw);
}

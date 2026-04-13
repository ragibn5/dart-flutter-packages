abstract interface class RequestCodec<Req, Res, Err> {
  /// Encodes [body] into a form that Dio can send over the wire.
  ///
  /// The return value is passed directly to Dio as the request `data`.
  /// Return `null` to send no body.
  ///
  /// Common implementations:
  /// - JSON: `return body.toJson();`
  /// - Form data: `return FormData.fromMap(body.toMap());`
  /// - Raw string: `return body.toString();`
  ///
  /// This method is only called when [body] is non-null.
  dynamic encodeBody(Req body);

  /// Decodes the raw Dio response data into [Res].
  ///
  /// [raw] is `response.data` as returned by Dio — typically a
  /// `Map<String, dynamic>`, `List<dynamic>`, or a primitive, depending on
  /// your Dio configuration and the server response.
  Res decodeResponse(dynamic raw);

  /// Decodes the raw Dio error response data into [Err].
  ///
  /// [raw] is `response.data` as returned by Dio on an error response.
  Err decodeError(dynamic raw);
}

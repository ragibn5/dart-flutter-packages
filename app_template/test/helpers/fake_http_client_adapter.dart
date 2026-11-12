import 'dart:typed_data';

import 'package:dio/dio.dart';

/// Answers every request with [respond], and records what it was sent.
class FakeHttpClientAdapter implements HttpClientAdapter {
  final ResponseBody Function(RequestOptions) respond;
  final requests = <RequestOptions>[];

  FakeHttpClientAdapter(this.respond);

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    return respond(options);
  }

  @override
  void close({bool force = false}) {}
}

/// A [Dio] whose requests [adapter] answers.
Dio fakeDio(
  FakeHttpClientAdapter adapter, {
  List<Interceptor> interceptors = const [],
}) {
  return Dio(BaseOptions(baseUrl: 'https://abc.com'))
    ..httpClientAdapter = adapter
    ..interceptors.addAll(interceptors);
}

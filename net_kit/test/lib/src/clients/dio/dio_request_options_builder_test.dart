// ignore_for_file: lines_longer_than_80_chars, avoid_redundant_argument_values

import 'package:dio/dio.dart';
import 'package:net_kit/src/clients/dio/dio_request_options_builder.dart';
import 'package:net_kit/src/enums/http_method.dart';
import 'package:net_kit/src/models/request_spec.dart';
import 'package:test/test.dart';

void main() {
  const sut = DioRequestOptionsBuilder();

  late RequestSpec composedSpec;

  setUp(() {
    composedSpec = RequestSpec(
      pathOrUrl: '/users',
      method: HttpMethod.POST,
      baseUrl: 'https://api.example.com',
      body: null,
      headers: const {'authorization': 'Bearer token'},
      queryParameters: const {'page': 1},
      contentType: Headers.jsonContentType,
      sendTimeout: const Duration(seconds: 2),
      receiveTimeout: const Duration(seconds: 3),
      connectionTimeout: const Duration(seconds: 4),
      followRedirects: false,
      maxRedirects: 1,
    );
  });

  test('build assigns path, method, and baseUrl', () {
    final requestOptions = sut.build(
      composedSpec: composedSpec,
      transformedBody: null,
      resolvedContentType: null,
      cancelToken: null,
      onSendProgress: null,
      onReceiveProgress: null,
    );

    expect(requestOptions.path, '/users');
    expect(requestOptions.method, 'POST');
    expect(requestOptions.baseUrl, 'https://api.example.com');
  });

  test('build assigns transformed body data', () {
    const body = {'name': 'Alice'};

    final requestOptions = sut.build(
      composedSpec: composedSpec,
      transformedBody: body,
      resolvedContentType: null,
      cancelToken: null,
      onSendProgress: null,
      onReceiveProgress: null,
    );

    expect(requestOptions.data, body);
  });

  test('build assigns null body when transformed body is null', () {
    final requestOptions = sut.build(
      composedSpec: composedSpec,
      transformedBody: null,
      resolvedContentType: null,
      cancelToken: null,
      onSendProgress: null,
      onReceiveProgress: null,
    );

    expect(requestOptions.data, isNull);
  });

  test('build assigns resolved content type', () {
    const contentType = 'application/vnd.custom+json';

    final requestOptions = sut.build(
      composedSpec: composedSpec,
      transformedBody: null,
      resolvedContentType: contentType,
      cancelToken: null,
      onSendProgress: null,
      onReceiveProgress: null,
    );

    expect(requestOptions.contentType, contentType);
  });

  test('build assigns null content type when not resolved', () {
    final requestOptions = sut.build(
      composedSpec: composedSpec,
      transformedBody: null,
      resolvedContentType: null,
      cancelToken: null,
      onSendProgress: null,
      onReceiveProgress: null,
    );

    expect(requestOptions.contentType, isNull);
  });

  test('build assigns cancelToken', () {
    final cancelToken = CancelToken();

    final requestOptions = sut.build(
      composedSpec: composedSpec,
      transformedBody: null,
      resolvedContentType: null,
      cancelToken: cancelToken,
      onSendProgress: null,
      onReceiveProgress: null,
    );

    expect(requestOptions.cancelToken, same(cancelToken));
  });

  test('build assigns null cancelToken', () {
    final requestOptions = sut.build(
      composedSpec: composedSpec,
      transformedBody: null,
      resolvedContentType: null,
      cancelToken: null,
      onSendProgress: null,
      onReceiveProgress: null,
    );

    expect(requestOptions.cancelToken, isNull);
  });

  test('build assigns timeouts from composedSpec', () {
    final requestOptions = sut.build(
      composedSpec: composedSpec,
      transformedBody: null,
      resolvedContentType: null,
      cancelToken: null,
      onSendProgress: null,
      onReceiveProgress: null,
    );

    expect(requestOptions.sendTimeout, const Duration(seconds: 2));
    expect(requestOptions.receiveTimeout, const Duration(seconds: 3));
    expect(requestOptions.connectTimeout, const Duration(seconds: 4));
  });

  test('build assigns headers and queryParameters from composedSpec', () {
    final requestOptions = sut.build(
      composedSpec: composedSpec,
      transformedBody: null,
      resolvedContentType: null,
      cancelToken: null,
      onSendProgress: null,
      onReceiveProgress: null,
    );

    expect(requestOptions.headers['authorization'], 'Bearer token');
    expect(requestOptions.queryParameters['page'], 1);
  });

  test('build assigns followRedirects and maxRedirects from composedSpec', () {
    final requestOptions = sut.build(
      composedSpec: composedSpec,
      transformedBody: null,
      resolvedContentType: null,
      cancelToken: null,
      onSendProgress: null,
      onReceiveProgress: null,
    );

    expect(requestOptions.followRedirects, false);
    expect(requestOptions.maxRedirects, 1);
  });

  test('build assigns progress listeners', () {
    void onSendProgress(_, __) {}

    void onReceiveProgress(_, __) {}

    final requestOptions = sut.build(
      composedSpec: composedSpec,
      transformedBody: null,
      resolvedContentType: null,
      cancelToken: null,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );

    expect(requestOptions.onSendProgress, same(onSendProgress));
    expect(requestOptions.onReceiveProgress, same(onReceiveProgress));
  });

  test('build sets validateStatus to always return true', () {
    final requestOptions = sut.build(
      composedSpec: composedSpec,
      transformedBody: null,
      resolvedContentType: null,
      cancelToken: null,
      onSendProgress: null,
      onReceiveProgress: null,
    );

    expect(requestOptions.validateStatus(200), isTrue);
    expect(requestOptions.validateStatus(400), isTrue);
    expect(requestOptions.validateStatus(500), isTrue);
    expect(requestOptions.validateStatus(0), isTrue);
  });
}

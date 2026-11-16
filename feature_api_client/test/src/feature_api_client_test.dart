import 'dart:typed_data';

import 'package:dart_functionals/dart_functionals.dart';
import 'package:dio/dio.dart';
import 'package:feature_api_client/feature_api_client.dart';
import 'package:mocktail/mocktail.dart';
import 'package:net_models/net_models.dart';
import 'package:test/test.dart';

class _MockDioExceptionTransformer extends Mock
    implements DioExceptionTransformer {}

/// Answers every request with [respond].
class _FakeAdapter implements HttpClientAdapter {
  final ResponseBody Function(RequestOptions) respond;

  _FakeAdapter(this.respond);

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async =>
      respond(options);

  @override
  void close({bool force = false}) {}
}

/// Sends a GET to the path it's given, and decodes the body as text: the
/// response on success, the error otherwise.
class _TestApiClient extends FeatureApiClient<String, String, String> {
  _TestApiClient(super.dio, {super.exceptionTransformer});

  @override
  Future<Response<Object?>> send(Dio dio, String body) =>
      dio.get<Object?>(body);

  @override
  ApiResponse<String, String> decodeResponse(Response<Object?> response) {
    final statusCode = response.statusCode!;
    final data = response.data! as String;
    if (statusCode >= 400) {
      return FailureResponse(
        error: data,
        statusCode: statusCode,
        headers: response.headers.map,
      );
    }
    return SuccessResponse(
      data: data,
      statusCode: statusCode,
      headers: response.headers.map,
    );
  }
}

void main() {
  late _MockDioExceptionTransformer mockTransformer;

  setUpAll(() {
    registerFallbackValue(DioException(requestOptions: RequestOptions()));
  });

  setUp(() {
    mockTransformer = _MockDioExceptionTransformer();
  });

  _TestApiClient build(ResponseBody Function(RequestOptions) respond) {
    final dio = Dio(BaseOptions(baseUrl: 'https://example.com'))
      ..httpClientAdapter = _FakeAdapter(respond);
    return _TestApiClient(dio, exceptionTransformer: mockTransformer);
  }

  ApiResponse<String, String> decoded(
    Either<ApiError, ApiResponse<String, String>> result,
  ) =>
      result.fold(
        onLeft: (e) => throw StateError('Expected a response, got $e'),
        onRight: (r) => r,
      );

  ApiError failed(Either<ApiError, ApiResponse<String, String>> result) =>
      result.fold(
        onLeft: (e) => e,
        onRight: (r) => throw StateError('Expected an error, got $r'),
      );

  test('requestShouldDecodeTheAnswerIfTheServerSucceeds', () async {
    final client = build((_) => ResponseBody.fromString('user', 200));

    final response = decoded(await client.request('/users/1'));

    expect(response, isA<SuccessResponse<String>>());
    expect((response as SuccessResponse<String>).data, 'user');
    expect(response.statusCode, 200);
  });

  test('requestShouldDecodeTheErrorBodyIfTheServerAnswersAnError', () async {
    final client = build((_) => ResponseBody.fromString('not found', 404));

    final response = decoded(await client.request('/users/1'));

    expect(response, isA<FailureResponse<String>>());
    expect((response as FailureResponse<String>).error, 'not found');
    expect(response.statusCode, 404);
  });

  test('requestShouldReturnTheMappedErrorIfThereIsNoAnswer', () async {
    const error = TransportError(type: TransportErrorType.CONNECTION_ERROR);
    when(() => mockTransformer.transformApiError(any())).thenReturn(error);
    final client = build(
      (o) => throw DioException.connectionError(
        requestOptions: o,
        reason: 'offline',
      ),
    );

    expect(failed(await client.request('/users/1')), error);
    final mapped = verify(
      () => mockTransformer.transformApiError(captureAny()),
    ).captured;
    expect(
      (mapped.single as DioException).type,
      DioExceptionType.connectionError,
    );
  });

  test('requestShouldReturnUnexpectedErrorIfTheAnswerCannotBeDecoded',
      () async {
    final client = build((_) => ResponseBody.fromString('', 204));

    final error = failed(await client.request('/users/1'));

    expect(error, isA<UnexpectedError>());
    expect((error as UnexpectedError).cause, isA<TypeError>());
  });
}

import 'package:core_models/core_models.dart';
import 'package:dart_functionals/dart_functionals.dart';
import 'package:feature_api_client/feature_api_client.dart';
import 'package:mocktail/mocktail.dart';
import 'package:net_kit/net_kit.dart';
import 'package:test/test.dart';

class _MockNetClient extends Mock implements NetClient {}

class _TestApiClient extends FeatureApiClient<String, int, String> {
  _TestApiClient(super.client);

  @override
  RequestSpec createRequest(String body) {
    return RequestSpec(pathOrUrl: body, method: HttpMethod.GET);
  }

  @override
  ApiResponse<String, int> decodeResponse(NetKitResponse response) {
    return Success(
      data: response.statusCode,
      statusCode: response.statusCode,
      headers: response.headers,
    );
  }
}

void main() {
  final requestSpec = RequestSpec(pathOrUrl: '/test', method: HttpMethod.GET);

  late _MockNetClient mockClient;

  late _TestApiClient sut;

  setUpAll(() {
    registerFallbackValue(RequestSpec(pathOrUrl: '', method: HttpMethod.GET));
    registerFallbackValue(const DefaultResponseClassifier());
  });

  setUp(() {
    mockClient = _MockNetClient();
    sut = _TestApiClient(mockClient);
  });

  test('Should return Right with decoded response on success', () async {
    const statusCode = 200;
    final netKitResponse = NetKitResponse(
      isError: false,
      statusCode: statusCode,
      data: null,
      headers: {},
      requestSpec: requestSpec,
    );
    when(
      () => mockClient.execute(
        spec: any(named: 'spec'),
        onSendProgress: any(named: 'onSendProgress'),
        onReceiveProgress: any(named: 'onReceiveProgress'),
        requestCanceller: any(named: 'requestCanceller'),
        responseClassifier: any(named: 'responseClassifier'),
      ),
    ).thenAnswer((_) async => Result.success(netKitResponse));

    final result = await sut.request('/test');

    expect(result.isRight, true);
    final apiResponse = result.rightOrThrow;
    expect(apiResponse, isA<Success<int>>());
    expect(apiResponse.statusCode, statusCode);
  });

  test('Should return Left with ApiError on exception', () async {
    final exception = TransportException(
      type: TransportExceptionType.CONNECTION_ERROR,
      request: requestSpec,
    );
    when(
      () => mockClient.execute(
        spec: any(named: 'spec'),
        onSendProgress: any(named: 'onSendProgress'),
        onReceiveProgress: any(named: 'onReceiveProgress'),
        requestCanceller: any(named: 'requestCanceller'),
        responseClassifier: any(named: 'responseClassifier'),
      ),
    ).thenAnswer((_) async => Result.error(exception));

    final result = await sut.request('/test');

    expect(result.isLeft, true);
    expect(result.leftOrThrow, isA<TransportError>());
  });
}

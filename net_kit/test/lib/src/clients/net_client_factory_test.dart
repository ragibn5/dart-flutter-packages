// ignore_for_file: avoid_redundant_argument_values

import 'package:dio/dio.dart';
import 'package:mocktail/mocktail.dart';
import 'package:net_kit/net_kit.dart';
import 'package:net_kit/src/clients/dio/dio_factory.dart';
import 'package:net_kit/src/clients/dio/dio_request_adapter.dart';
import 'package:net_kit/src/clients/net_client_impl.dart';
import 'package:test/test.dart';

class _MockDio extends Mock implements Dio {}

class _MockDioFactory extends Mock implements DioFactory {}

class _FakeInterceptor extends NetKitInterceptor {}

void main() {
  const clientConfig = ClientConfig();

  late _MockDio mockDio;
  late _MockDioFactory mockDioFactory;

  late NetClientFactory sut;

  setUp(() {
    mockDio = _MockDio();
    mockDioFactory = _MockDioFactory();

    sut = NetClientFactory.test(mockDioFactory);

    when(() => mockDioFactory.createDio(clientConfig)).thenReturn(mockDio);
  });

  test('Create returns a NetClient using proper values', () {
    final interceptor = _FakeInterceptor();
    final client = sut.create(
      clientConfig: clientConfig,
      interceptors: [interceptor],
    );

    verify(() => mockDioFactory.createDio(clientConfig)).called(1);
    expect(
      client,
      isA<NetClientImpl>()
          .having((p) => p.clientConfig, 'clientConfig', same(clientConfig))
          .having(
            (p) => p.requestAdapter,
            'requestAdapter',
            isA<DioRequestAdapter>(),
          )
          .having(
            (p) => p.interceptors.snapshot(),
            'interceptors',
            allOf(hasLength(1), contains(interceptor)),
          ),
    );

    client.close();
  });
}

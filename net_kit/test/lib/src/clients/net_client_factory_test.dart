import 'package:net_kit/src/clients/dio/dio_net_client.dart';
import 'package:net_kit/src/clients/net_client.dart';
import 'package:net_kit/src/clients/net_client_factory.dart';
import 'package:net_kit/src/models/default_client_config.dart';
import 'package:test/test.dart';

void main() {
  test('Create returns a NetClient using default config', () {
    final client = NetClientFactory.create();

    expect(client, isA<NetClient>());
    expect(client, isA<DioNetClient>());

    client.close();
  });

  test('Create accepts an explicit DefaultClientConfig', () {
    final client = NetClientFactory.create(
      const DefaultClientConfig(
        baseUrl: 'https://api.example.com',
        connectionTimeout: Duration(seconds: 5),
        sendTimeout: Duration(seconds: 3),
        receiveTimeout: Duration(seconds: 4),
        headers: {'authorization': 'Bearer token'},
        queryParameters: {'locale': 'en'},
      ),
    );

    expect(client, isA<DioNetClient>());

    client.close();
  });
}

import 'package:net_kit/net_kit.dart';

Future<void> main() async {
  final client = NetClientFactory().create(
    clientConfig: const ClientConfig(
      baseUrl: 'https://example.com/api',
      connectionTimeout: Duration(seconds: 5),
      receiveTimeout: Duration(seconds: 5),
    ),
  );

  const request = RequestSpec(
    pathOrUrl: '/users',
    method: HttpMethod.POST,
    body: JsonBody({
      'name': 'Ragib',
    }),
    sendTimeout: Duration(seconds: 2),
    receiveTimeout: Duration(seconds: 2),
  );

  final result = await client.execute(spec: request);

  result.fold(
    onSuccess: (response) {
      print('Success: ${response.data}');
    },
    onError: (error) {
      switch (error) {
        case TransportException(type: final type):
          print('Transport error: $type');
        case UnexpectedException(message: final message):
          print('Unexpected error: $message');
        case CancellationException():
          print('Request was cancelled');
      }
    },
  );
}

import 'package:net_kit/src/clients/dio/dio_net_client.dart';
import 'package:net_kit/src/clients/net_client.dart';
import 'package:net_kit/src/models/default_client_config.dart';

/// Public construction entry point for [NetClient] implementations.
final class NetClientFactory {
  const NetClientFactory._();

  static NetClient create([
    DefaultClientConfig config = const DefaultClientConfig(),
  ]) {
    return DioNetClient(config);
  }
}

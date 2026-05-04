import 'package:meta/meta.dart';
import 'package:net_kit/src/clients/dio/dio_factory.dart';
import 'package:net_kit/src/clients/dio/dio_request_adapter.dart';
import 'package:net_kit/src/clients/net_client.dart';
import 'package:net_kit/src/models/client_config.dart';
import 'package:net_kit/src/services/interceptor/net_kit_interceptor.dart';

/// Public construction entry point for [NetClient] implementations.
final class NetClientFactory {
  final DioFactory _dioFactory;

  NetClientFactory() : this._(const DioFactory());

  @visibleForTesting
  const NetClientFactory.test(DioFactory dioFactory) : this._(dioFactory);

  const NetClientFactory._(this._dioFactory);

  NetClient create([
    ClientConfig clientConfig = const ClientConfig(),
    List<NetKitInterceptor> interceptors = const [],
  ]) {
    return NetClient(
      clientConfig: clientConfig,
      interceptors: interceptors,
      requestAdapter: DioRequestAdapter(_dioFactory.createDio(clientConfig)),
    );
  }
}

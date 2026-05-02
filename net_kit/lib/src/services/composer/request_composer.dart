import 'package:net_kit/src/models/default_client_config.dart';
import 'package:net_kit/src/models/request_spec.dart';

/// An interface to compose a [RequestSpec] with the given client specific
/// [DefaultClientConfig].
///
class RequestComposer {
  const RequestComposer();

  /// Builds a merged a [RequestSpec] from the given [RequestSpec] and
  /// [DefaultClientConfig].
  ///
  /// Note:
  /// - Values from [source] receives precedence over the [clientConfig].
  /// - For collection type fields, such as headers and query params,
  ///   the resulting value is the result of merging all the map entries,
  ///   where values from [source] receive precedence over [clientConfig].
  RequestSpec compose(RequestSpec source, DefaultClientConfig clientConfig) {
    return source.copyWith(
      sendTimeout: source.sendTimeout ?? clientConfig.sendTimeout,
      receiveTimeout: source.receiveTimeout ?? clientConfig.receiveTimeout,
      connectionTimeout:
          source.connectionTimeout ?? clientConfig.connectionTimeout,
      queryParameters: (clientConfig.queryParameters ?? {})
        ..addAll(source.queryParameters ?? {}),
      headers: (clientConfig.headers ?? {})..addAll(source.headers ?? {}),
      baseUrl: source.baseUrl ?? clientConfig.baseUrl,
      followRedirects: source.followRedirects ?? clientConfig.followRedirects,
      maxRedirects: source.maxRedirects ?? clientConfig.maxRedirects,
    );
  }
}

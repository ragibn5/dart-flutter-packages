import 'package:net_kit/net_kit.dart';

/// An interface to compose a [RequestSpec] with the given client specific
/// [ClientConfig].
///
abstract interface class RequestComposer {
  /// Builds a merged a [RequestSpec] from the given [RequestSpec] and
  /// [ClientConfig].
  ///
  /// Note:
  /// - Values from [source] receives precedence over the [clientConfig].
  /// - For collection type fields, such as headers and query params,
  ///   the resulting value is the result of merging all the map entries,
  ///   where values from [source] receive precedence over [clientConfig].
  RequestSpec compose(RequestSpec source, ClientConfig clientConfig);
}

class DefaultRequestComposer implements RequestComposer {
  const DefaultRequestComposer();

  @override
  RequestSpec compose(RequestSpec source, ClientConfig clientConfig) {
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

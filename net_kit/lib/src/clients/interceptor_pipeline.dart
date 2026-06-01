import 'package:net_kit/src/clients/net_client.dart';
import 'package:net_kit/src/services/interceptors/net_kit_interceptor.dart';

/// Manages the ordered list of interceptors for a [NetClient].
///
/// Owns its own list — no external reference is shared.
final class InterceptorPipeline {
  final List<NetKitInterceptor> _interceptors;

  InterceptorPipeline({List<NetKitInterceptor> interceptors = const []})
      : _interceptors = List.of(interceptors);

  /// Appends [interceptor] to the end of the chain.
  void add(NetKitInterceptor interceptor) => _interceptors.add(interceptor);

  /// Appends all [interceptors] to the end of the chain, in given order.
  void addAll(Iterable<NetKitInterceptor> interceptors) =>
      _interceptors.addAll(interceptors);

  /// Removes the first occurrence of [interceptor].
  /// Returns `true` if the interceptor was found and removed.
  bool remove(NetKitInterceptor interceptor) =>
      _interceptors.remove(interceptor);

  /// Removes all interceptors from the chain.
  void clear() => _interceptors.clear();

  /// The number of interceptors in the pipeline.
  int get length => _interceptors.length;

  /// Whether the pipeline is empty.
  bool get isEmpty => _interceptors.isEmpty;

  /// Returns a snapshot copy of the current interceptor list.
  List<NetKitInterceptor> snapshot() => List.of(_interceptors);
}

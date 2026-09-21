import 'package:meta/meta.dart';
import 'package:rover/src/models/route_info.dart';

@immutable
class RouteContext {
  final RouteInfo info;

  final Map<String, String> pathParameters;
  final Map<String, String> queryParameters;
  final Object? extra;

  const RouteContext({
    required this.info,
    this.pathParameters = const {},
    this.queryParameters = const {},
    this.extra,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RouteContext &&
          runtimeType == other.runtimeType &&
          info == other.info &&
          pathParameters == other.pathParameters &&
          queryParameters == other.queryParameters &&
          extra == other.extra;

  @override
  int get hashCode => Object.hash(info, pathParameters, queryParameters, extra);
}

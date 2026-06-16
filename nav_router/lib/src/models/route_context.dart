import 'package:nav_router/src/models/route_info.dart';

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
}

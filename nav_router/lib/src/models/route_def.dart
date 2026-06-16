import 'package:nav_router/src/models/route_info.dart';
import 'package:nav_router/src/services/route_guard.dart';
import 'package:nav_router/src/typedefs/route_widget_builder.dart';

class RouteDef {
  final RouteInfo info;
  final RouteWidgetBuilder builder;
  final List<RouteGuard> guards;

  const RouteDef({
    required this.info,
    required this.builder,
    this.guards = const [],
  });
}

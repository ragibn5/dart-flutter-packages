import 'package:nav_router/src/models/route_info.dart';
import 'package:nav_router/src/typedefs/route_widget_builder.dart';

class RouteDef {
  final RouteInfo info;
  final RouteWidgetBuilder builder;

  const RouteDef({required this.info, required this.builder});
}

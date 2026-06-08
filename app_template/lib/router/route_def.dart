import 'package:app_template/router/route_info.dart';
import 'package:app_template/router/route_widget_builder.dart';

class RouteDef {
  final RouteInfo info;
  final RouteWidgetBuilder builder;

  const RouteDef({required this.info, required this.builder});
}

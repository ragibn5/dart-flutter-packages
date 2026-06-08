import 'package:app_template/router/route_widget_builder.dart';

class RouteDef {
  final String name;
  final String path;
  final RouteWidgetBuilder builder;

  const RouteDef({
    required this.name,
    required this.path,
    required this.builder,
  });
}

import 'package:app_template/router/route_info.dart';

enum AppRoute {
  ROOT(RouteInfo('root', '/')),
  LOGIN(RouteInfo('login', '/login')),
  HOME(RouteInfo('home', '/home'));

  final RouteInfo routeInfo;

  const AppRoute(this.routeInfo);
}

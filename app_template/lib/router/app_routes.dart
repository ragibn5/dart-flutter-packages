import 'package:app_template/router/route_info.dart';

enum AppRoutes {
  ROOT(RouteInfo('root', '/')),
  LOGIN(RouteInfo('login', '/login')),
  HOME(RouteInfo('home', '/home'));

  final RouteInfo routeInfo;

  const AppRoutes(this.routeInfo);
}

import 'package:nav_router/nav_router.dart';

enum AppRoute {
  ROOT(RouteInfo('root', '/')),
  LOGIN(RouteInfo('login', '/login')),
  HOME(RouteInfo('home', '/home'));

  final RouteInfo routeInfo;

  const AppRoute(this.routeInfo);
}

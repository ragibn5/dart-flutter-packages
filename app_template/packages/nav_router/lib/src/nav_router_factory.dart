import 'package:flutter/widgets.dart';
import 'package:nav_router/src/go_route/go_route_app_router.dart';
import 'package:nav_router/src/models/route_def.dart';
import 'package:nav_router/src/models/route_info.dart';
import 'package:nav_router/src/nav_router.dart';
import 'package:nav_router/src/services/route_guard.dart';

class NavRouterFactory {
  NavRouter create({
    required GlobalKey<NavigatorState> navigatorKey,
    required RouteInfo initialRoute,
    required List<RouteDef> routes,
    List<RouteGuard> guards = const [],
  }) {
    return GoRouteAppRouter(
      navigatorKey: navigatorKey,
      initialRoute: initialRoute,
      routes: routes,
      guards: guards,
    );
  }
}

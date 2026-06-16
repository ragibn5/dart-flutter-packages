import 'package:flutter/material.dart';
import 'package:nav_router/nav_router.dart';

void main() {
  final router = NavRouterFactory().create(
    navigatorKey: GlobalKey<NavigatorState>(),
    initialRoute: RouteInfo('home', '/'),
    routes: [
      RouteDef(
        info: RouteInfo('home', '/'),
        builder: (context, router, routeContext) => const SizedBox(),
      ),
    ],
  );

  print('Router config: ${router.routerConfig}');
}

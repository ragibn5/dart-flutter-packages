import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:nav_router/src/models/route_context.dart';

abstract class NavRouter {
  RouterConfig<Object> get routerConfig;

  RouteContext get currentRoute;

  Future<T?> pushWithName<T extends Object?>(
    String routeName, {
    Map<String, String> pathParameters = const {},
    Map<String, String> queryParameters = const {},
    Object? extra,
  });

  Future<T?> replaceWithName<T extends Object?>(
    String routeName, {
    Map<String, String> pathParameters = const {},
    Map<String, String> queryParameters = const {},
    Object? extra,
  });

  void navigateTo(
    String routeName, {
    Map<String, String> pathParameters = const {},
    Map<String, String> queryParameters = const {},
    Object? extra,
  });

  bool canPopTopRoute();

  void popTopRoute<T extends Object?>([T? result]);

  void popUntilRoute(bool Function(RouteContext) predicate);
}

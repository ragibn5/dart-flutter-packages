import 'dart:async';

import 'package:flutter/widgets.dart';

abstract class NavRouter {
  RouterConfig<Object> get routerConfig;

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

  bool canPopTopRoute();

  void popTopRoute<T extends Object?>([T? result]);
}

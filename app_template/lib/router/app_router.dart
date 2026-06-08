import 'dart:async';

import 'package:flutter/material.dart';

abstract class AppRouter {
  RouterConfig<Object> get routerConfig;

  Future<T?> pushWithName<T extends Object?>(
    String routeName, {
    Map<String, String> pathParameters = const {},
    Map<String, Object?> queryParameters = const {},
    Object? extra,
  });

  Future<T?> replaceWithName<T extends Object?>(
    String routeName, {
    Map<String, String> pathParameters = const {},
    Map<String, Object?> queryParameters = const {},
    Object? extra,
  });

  void popTopRoute<T extends Object?>([T? result]);
}

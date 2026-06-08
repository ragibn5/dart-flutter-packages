import 'dart:async';

import 'package:flutter/material.dart';

abstract class AppRouter {
  RouterConfig<Object> get routerConfig;

  Future<T?> pushWithName<T extends Object?>(String routeName);

  Future<T?> replaceWithName<T extends Object?>(String routeName);

  void popTopRoute<T extends Object?>([T? result]);
}

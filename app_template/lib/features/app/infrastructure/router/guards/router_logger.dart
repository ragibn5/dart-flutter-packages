import 'package:flutter/material.dart';
import 'package:nav_router/nav_router.dart';

class RouterLoggerGuard implements RouteGuard {
  @override
  Future<GuardResult> onNavigationRequest(
    BuildContext context,
    RouteContext current,
    RouteContext next,
  ) async {
    print('Routing: ${current.info.path} -> ${next.info.path}');
    return Continue();
  }
}

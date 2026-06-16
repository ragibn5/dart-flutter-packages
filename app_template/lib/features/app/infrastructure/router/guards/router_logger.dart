import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:nav_router/nav_router.dart';

class RouterLogger implements RouteGuard {
  @override
  Future<GuardResult> onNavigationRequest(
    BuildContext context,
    RouteContext current,
    RouteContext next,
  ) async {
    log('Routing: ${current.info.path} -> ${next.info.path}');
    return ContinueNavigation();
  }
}

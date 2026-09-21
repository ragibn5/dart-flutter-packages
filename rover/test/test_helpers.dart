import 'package:flutter/material.dart';
import 'package:rover/rover.dart';

class TestGuard implements RouteGuard {
  @override
  Future<GuardResult> onNavigationRequest(
    BuildContext context,
    RouteContext current,
    RouteContext next,
  ) async => ContinueNavigation(current: current, next: next);
}

class TestBlockGuard implements RouteGuard {
  @override
  Future<GuardResult> onNavigationRequest(
    BuildContext context,
    RouteContext current,
    RouteContext next,
  ) async => BlockNavigation(current: current, blocked: next);
}

class TestRedirectGuard implements RouteGuard {
  @override
  Future<GuardResult> onNavigationRequest(
    BuildContext context,
    RouteContext current,
    RouteContext next,
  ) async => RedirectNavigation(
    current: current,
    redirectRoute: const RouteContext(info: RouteInfo('login', '/login')),
  );
}

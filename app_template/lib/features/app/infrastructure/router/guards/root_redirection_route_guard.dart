import 'package:app_template/features/app/application/use_cases/is_authed_use_case.dart';
import 'package:app_template/features/app/infrastructure/enums/app_route.dart';
import 'package:flutter/material.dart';
import 'package:rover/rover.dart';

class RootRedirectRouteGuard implements RouteGuard {
  final IsAuthedUseCase _isAuthed;

  RootRedirectRouteGuard(this._isAuthed);

  @override
  Future<GuardResult> onNavigationRequest(
    BuildContext context,
    RouteContext current,
    RouteContext next,
  ) async {
    final isAuthed = await _isAuthed();
    if (!isAuthed) {
      return RedirectNavigation(
        current: current,
        redirectRoute: RouteContext(info: AppRoute.LOGIN.routeInfo),
      );
    } else {
      return RedirectNavigation(
        current: current,
        redirectRoute: RouteContext(info: AppRoute.HOME.routeInfo),
      );
    }
  }
}

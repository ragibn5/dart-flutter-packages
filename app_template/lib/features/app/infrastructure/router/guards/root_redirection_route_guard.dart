import 'package:app_template/features/app/application/use_cases/get_auth_state_use_case.dart';
import 'package:app_template/features/app/infrastructure/enums/app_route.dart';
import 'package:flutter/material.dart';
import 'package:nav_router/nav_router.dart';

class RootRedirectRouteGuard implements RouteGuard {
  final GetAuthStateUseCase _getAuthState;

  RootRedirectRouteGuard(this._getAuthState);

  @override
  Future<GuardResult> onNavigationRequest(
    BuildContext context,
    RouteContext current,
    RouteContext next,
  ) async {
    final currentAuthData = await _getAuthState();
    if (currentAuthData) {
      return RedirectNavigation(RouteContext(info: AppRoute.LOGIN.routeInfo));
    } else {
      return RedirectNavigation(RouteContext(info: AppRoute.HOME.routeInfo));
    }
  }
}

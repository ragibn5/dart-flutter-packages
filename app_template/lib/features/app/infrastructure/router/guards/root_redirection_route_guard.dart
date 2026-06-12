import 'package:app_template/features/app/infrastructure/enums/app_route.dart';
import 'package:app_template/features/auth/domain/services/auth_data_service.dart';
import 'package:flutter/material.dart';
import 'package:nav_router/nav_router.dart';

class RootRedirectRouteGuard implements RouteGuard {
  final AuthDataService _authDataService;

  RootRedirectRouteGuard(this._authDataService);

  @override
  Future<GuardResult> onNavigationRequest(
    BuildContext context,
    RouteContext current,
    RouteContext next,
  ) async {
    final currentAuthData = await _authDataService.getCurrentAuthData();
    final isOnLogin = current.info.name == AppRoute.LOGIN.routeInfo.name;

    if (currentAuthData == null) {
      return Redirect(RouteContext(info: AppRoute.LOGIN.routeInfo));
    } else {
      return Redirect(RouteContext(info: AppRoute.HOME.routeInfo));
    }
  }
}

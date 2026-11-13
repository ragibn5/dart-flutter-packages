import 'package:app_template/features/app/application/use_cases/is_authed_use_case.dart';
import 'package:app_template/features/app/infrastructure/enums/app_route.dart';
import 'package:app_template/features/app/infrastructure/router/guards/route_redirect.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Sends the root to the login page, or the home page.
class RootRedirectRouteGuard implements RouteRedirect {
  final IsAuthedUseCase _isAuthed;

  RootRedirectRouteGuard(this._isAuthed);

  @override
  Future<String?> call(BuildContext context, GoRouterState state) async {
    final isAuthed = await _isAuthed();
    final route = isAuthed ? AppRoute.HOME : AppRoute.LOGIN;
    return state.namedLocation(route.routeName);
  }
}

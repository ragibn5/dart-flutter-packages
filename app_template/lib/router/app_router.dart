import 'package:app_logger/app_logger.dart';
import 'package:app_template/features/auth/domain/services/auth_data_service.dart';
import 'package:app_template/router/app_router.gr.dart';
import 'package:app_template/router/guards/root_redirection_route_guard.dart';
import 'package:app_template/router/guards/router_logger.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  final AppLogger _logger;
  final AuthDataService _authDataService;

  AppRouter(
    GlobalKey<NavigatorState> rootNavigatorState,
    this._logger,
    this._authDataService,
  ) : super(navigatorKey: rootNavigatorState);

  @protected
  @override
  List<AutoRoute> get routes => [
    AutoRoute(
      initial: true,
      page: RootRedirectionRoute.page,
      guards: [RootRedirectionRouteGuard(_authDataService)],
    ),
    AutoRoute(page: LoginRoute.page),
    AutoRoute(page: HomeRoute.page),
  ];

  @protected
  @override
  List<AutoRouteGuard> get guards => [RouterLogger(_logger)];
}

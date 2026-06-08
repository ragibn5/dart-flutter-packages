import 'package:app_logger/app_logger.dart';
import 'package:app_template/features/auth/domain/services/auth_data_service.dart';
import 'package:app_template/router/app_router.dart';
import 'package:app_template/router/app_routes.dart';
import 'package:app_template/router/auto_route/guards/root_redirection_route_guard.dart';
import 'package:app_template/router/auto_route/guards/router_logger.dart';
import 'package:app_template/router/route_context.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

@AutoRouterConfig()
class AutoRouteAppRouter extends RootStackRouter implements AppRouter {
  final AppLogger _logger;
  final AuthDataService _authDataService;

  AutoRouteAppRouter(
    GlobalKey<NavigatorState> rootNavigatorState,
    this._logger,
    this._authDataService,
  ) : super(navigatorKey: rootNavigatorState);

  @override
  RouterConfig<Object> get routerConfig => super.config(
    reevaluateListenable: ReevaluateListenable.stream(
      _authDataService.watchAuthData(),
    ),
  );

  @override
  Future<T?> pushWithName<T extends Object?>(
    String routeName, {
    Map<String, String> pathParameters = const {},
    Map<String, String> queryParameters = const {},
    Object? extra,
  }) => push<T>(
    NamedRoute(
      routeName,
      params: pathParameters,
      queryParams: queryParameters,
      args: extra,
    ),
  );

  @override
  Future<T?> replaceWithName<T extends Object?>(
    String routeName, {
    Map<String, String> pathParameters = const {},
    Map<String, String> queryParameters = const {},
    Object? extra,
  }) => replace<T>(
    NamedRoute(
      routeName,
      params: pathParameters,
      queryParams: queryParameters,
      args: extra,
    ),
  );

  @override
  void popTopRoute<T extends Object?>([T? result]) => pop<T>(result);

  @protected
  @override
  List<AutoRoute> get routes => appRouteDefs
      .map(
        (r) => NamedRouteDef(
          name: r.name,
          path: r.path,
          initial: r.name == AppRoutes.ROOT.routeInfo.name,
          guards: r.name == AppRoutes.ROOT.routeInfo.name
              ? [RootRedirectionRouteGuard(_authDataService)]
              : [],
          builder: (c, d) => r.builder(
            c,
            RouteContext(
              pathParameters: d.params.rawMap.map(
                (k, v) => MapEntry(k, v.toString()),
              ),
              queryParameters: d.queryParams.rawMap.map(
                (k, v) => MapEntry(k, v.toString()),
              ),
              extra: d.args,
            ),
          ),
        ),
      )
      .toList();

  @protected
  @override
  List<AutoRouteGuard> get guards => [RouterLogger(_logger)];
}

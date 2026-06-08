import 'package:app_logger/app_logger.dart';
import 'package:app_template/features/auth/domain/services/auth_data_service.dart';
import 'package:app_template/router/app_router.dart';
import 'package:app_template/router/app_routes.dart';
import 'package:app_template/router/go_route/observers/router_logger.dart';
import 'package:app_template/router/route_context.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class GoRouteAppRouter implements AppRouter {
  final GlobalKey<NavigatorState> _navigatorKey;

  final AppLogger _logger;
  final AuthDataService _authDataService;

  late final GoRouter _router = _buildRouter();

  GoRouteAppRouter({
    required GlobalKey<NavigatorState> navigatorKey,
    required AppLogger logger,
    required AuthDataService authDataService,
  }) : _navigatorKey = navigatorKey,
       _logger = logger,
       _authDataService = authDataService;

  @override
  RouterConfig<Object> get routerConfig => _router;

  @override
  Future<T?> pushWithName<T extends Object?>(
    String routeName, {
    Map<String, String> pathParameters = const {},
    Map<String, Object?> queryParameters = const {},
    Object? extra,
  }) => _router.pushNamed<T>(
    routeName,
    pathParameters: pathParameters,
    queryParameters: queryParameters,
    extra: extra,
  );

  @override
  Future<T?> replaceWithName<T extends Object?>(
    String routeName, {
    Map<String, String> pathParameters = const {},
    Map<String, Object?> queryParameters = const {},
    Object? extra,
  }) => _router.replaceNamed<T>(
    routeName,
    pathParameters: pathParameters,
    queryParameters: queryParameters,
    extra: extra,
  );

  @override
  void popTopRoute<T extends Object?>([T? result]) => _router.pop<T>(result);

  GoRouter _buildRouter() {
    return GoRouter(
      navigatorKey: _navigatorKey,
      initialLocation: AppRoutes.ROOT.routeInfo.path,
      redirect: buildRootRedirect,
      observers: [RouterLogger(_logger)],
      routes: appRouteDefs
          .map(
            (r) => GoRoute(
              path: r.path,
              name: r.name,
              builder: (context, state) => r.builder(
                context,
                RouteContext(
                  pathParameters: state.pathParameters,
                  queryParameters: state.uri.queryParameters,
                  extra: state.extra,
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  Future<String?> buildRootRedirect(
    BuildContext context,
    GoRouterState state,
  ) async {
    final currentAuthData = await _authDataService.getCurrentAuthData();
    final isOnLogin = state.matchedLocation == AppRoutes.LOGIN.routeInfo.path;

    if (currentAuthData == null && !isOnLogin) {
      return AppRoutes.LOGIN.routeInfo.path;
    }
    if (currentAuthData != null && isOnLogin) {
      return AppRoutes.HOME.routeInfo.path;
    }

    return null;
  }
}

import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart' as grouter;
import 'package:nav_router/src/models/guard_result.dart';
import 'package:nav_router/src/models/route_context.dart';
import 'package:nav_router/src/models/route_def.dart';
import 'package:nav_router/src/models/route_info.dart';
import 'package:nav_router/src/nav_router.dart';
import 'package:nav_router/src/services/route_guard.dart';

class GoRouteAppRouter implements NavRouter {
  final GlobalKey<NavigatorState> _navigatorKey;
  final RouteInfo _initialRoute;
  final List<RouteDef> _routes;
  final List<RouteGuard> _guards;

  late final grouter.GoRouter _router = grouter.GoRouter(
    navigatorKey: _navigatorKey,
    initialLocation: _initialRoute.path,
    onEnter: _handleGuards,
    routes: _routes
        .map(
          (r) => grouter.GoRoute(
            name: r.info.name,
            path: r.info.path,
            builder: (context, state) => r.builder(
              context,
              this,
              RouteContext(
                info: r.info,
                pathParameters: state.pathParameters,
                queryParameters: state.uri.queryParameters,
                extra: state.extra,
              ),
            ),
          ),
        )
        .toList(),
  );

  GoRouteAppRouter({
    required GlobalKey<NavigatorState> navigatorKey,
    required RouteInfo initialRoute,
    required List<RouteDef> routes,
    List<RouteGuard> guards = const [],
  }) : _navigatorKey = navigatorKey,
       _initialRoute = initialRoute,
       _routes = routes,
       _guards = guards;

  @override
  RouterConfig<Object> get routerConfig => _router;

  @override
  Future<T?> pushWithName<T extends Object?>(
    String routeName, {
    Map<String, String> pathParameters = const {},
    Map<String, String> queryParameters = const {},
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
    Map<String, String> queryParameters = const {},
    Object? extra,
  }) => _router.replaceNamed<T>(
    routeName,
    pathParameters: pathParameters,
    queryParameters: queryParameters,
    extra: extra,
  );

  @override
  bool canPopTopRoute() => _router.canPop();

  @override
  void popTopRoute<T extends Object?>([T? result]) => _router.pop<T>(result);

  Future<grouter.OnEnterResult> _handleGuards(
    BuildContext context,
    grouter.GoRouterState currentState,
    grouter.GoRouterState nextState,
    grouter.GoRouter router,
  ) async {
    final current = RouteContext(
      info: RouteInfo(currentState.name!, currentState.path!),
      pathParameters: currentState.pathParameters,
      queryParameters: currentState.uri.queryParameters,
      extra: currentState.extra,
    );
    final next = RouteContext(
      info: RouteInfo(nextState.name!, nextState.path!),
      pathParameters: nextState.pathParameters,
      queryParameters: nextState.uri.queryParameters,
      extra: nextState.extra,
    );

    final routeDef = _routes.firstWhere(
      (r) => r.info.name == nextState.name || r.info.path == nextState.path,
    );
    final allGuards = [
      // root guards
      ..._guards,
      // route guards
      ...routeDef.guards,
    ];

    for (final guard in allGuards) {
      final result = await guard.onNavigationRequest(context, current, next);
      switch (result) {
        case Block():
          return const grouter.Block.stop();
        case Redirect():
          return grouter.Block.then(
            () => router.goNamed(
              result.redirectRoute.info.name,
              pathParameters: result.redirectRoute.pathParameters,
              queryParameters: result.redirectRoute.queryParameters,
              extra: result.redirectRoute.extra,
            ),
          );
        case Continue():
          break;
      }
    }

    return const grouter.Allow();
  }
}

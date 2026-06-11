import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart' as grouter;
import 'package:nav_router/src/go_route/adapter/go_route_observer_adapter.dart';
import 'package:nav_router/src/models/guard_result.dart';
import 'package:nav_router/src/models/route_context.dart';
import 'package:nav_router/src/models/route_def.dart';
import 'package:nav_router/src/models/route_info.dart';
import 'package:nav_router/src/nav_router.dart';
import 'package:nav_router/src/services/route_guard.dart';
import 'package:nav_router/src/services/router_observer.dart';

class GoRouteAppRouter implements NavRouter {
  final GlobalKey<NavigatorState> _navigatorKey;
  final RouteInfo _initialRoute;
  final List<RouteDef> _routes;
  final List<RouterObserver> _observers;
  final List<RouteGuard> _guards;

  late final grouter.GoRouter _router = grouter.GoRouter(
    navigatorKey: _navigatorKey,
    initialLocation: _initialRoute.path,
    onEnter: _handleRouterGuards,
    observers: _observers.map(GoRouteObserverAdapter.new).toList(),
    routes: _routes
        .map(
          (r) => grouter.GoRoute(
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
    List<RouterObserver> observers = const [],
    List<RouteGuard> guards = const [],
  }) : _navigatorKey = navigatorKey,
       _initialRoute = initialRoute,
       _routes = routes,
       _observers = observers,
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
  void popTopRoute<T extends Object?>([T? result]) => _router.pop<T>(result);

  Future<grouter.OnEnterResult> _handleRouterGuards(
    BuildContext context,
    grouter.GoRouterState state,
    grouter.GoRouterState nextState,
    grouter.GoRouter router,
  ) async {
    final current = RouteContext(
      info: RouteInfo(state.name!, state.path!),
      pathParameters: state.pathParameters,
      queryParameters: state.uri.queryParameters,
      extra: state.extra,
    );
    final next = RouteContext(
      info: RouteInfo(nextState.name!, nextState.path!),
      pathParameters: nextState.pathParameters,
      queryParameters: nextState.uri.queryParameters,
      extra: nextState.extra,
    );

    for (final guard in _guards) {
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

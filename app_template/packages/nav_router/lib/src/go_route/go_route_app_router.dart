import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:nav_router/src/go_route/adapter/go_route_observer_adapter.dart';
import 'package:nav_router/src/models/route_context.dart';
import 'package:nav_router/src/models/route_def.dart';
import 'package:nav_router/src/models/route_info.dart';
import 'package:nav_router/src/nav_router.dart';
import 'package:nav_router/src/services/router_observer.dart';

class GoRouteAppRouter implements NavRouter {
  final GlobalKey<NavigatorState> _navigatorKey;
  final RouteInfo _initialRoute;
  final List<RouteDef> _routes;
  final List<RouterObserver> _observers;

  late final GoRouter _router = GoRouter(
    navigatorKey: _navigatorKey,
    initialLocation: _initialRoute.path,
    observers: _observers.map(GoRouteObserverAdapter.new).toList(),
    routes: _routes
        .map(
          (r) => GoRoute(
            path: r.info.path,
            name: r.info.name,
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
  }) : _navigatorKey = navigatorKey,
       _initialRoute = initialRoute,
       _routes = routes,
       _observers = observers;

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
}

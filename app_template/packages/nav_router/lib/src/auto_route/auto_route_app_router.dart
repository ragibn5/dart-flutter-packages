import 'package:auto_route/auto_route.dart';
import 'package:flutter/widgets.dart';
import 'package:nav_router/src/auto_route/adapter/auto_route_observer_adapter.dart';
import 'package:nav_router/src/models/route_context.dart';
import 'package:nav_router/src/models/route_def.dart';
import 'package:nav_router/src/models/route_info.dart';
import 'package:nav_router/src/nav_router.dart';
import 'package:nav_router/src/services/router_observer.dart';

@AutoRouterConfig()
class AutoRouteAppRouter extends RootStackRouter implements NavRouter {
  final List<RouteDef> _routes;
  final RouteInfo? _initialRoute;
  final List<RouterObserver> _observers;

  AutoRouteAppRouter({
    required GlobalKey<NavigatorState> navigatorKey,
    required RouteInfo initialRoute,
    required List<RouteDef> routes,
    List<RouterObserver> observers = const [],
  }) : _initialRoute = initialRoute,
       _routes = routes,
       _observers = observers,
       super(navigatorKey: navigatorKey);

  @override
  RouterConfig<Object> get routerConfig => super.config();

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
  List<AutoRoute> get routes => _routes
      .map(
        (r) => NamedRouteDef(
          name: r.info.name,
          path: r.info.path,
          initial: r.info.path == _initialRoute?.path,
          builder: (c, d) => r.builder(
            c,
            this,
            RouteContext(
              info: r.info,
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
  List<AutoRouteGuard> get guards => [
    ..._observers.map(AutoRouteObserverAdapter.new),
  ];
}

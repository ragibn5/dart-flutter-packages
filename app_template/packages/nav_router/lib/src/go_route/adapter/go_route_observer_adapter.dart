import 'package:flutter/widgets.dart';
import 'package:nav_router/src/models/navigation_event.dart';
import 'package:nav_router/src/services/router_observer.dart';

class GoRouteObserverAdapter extends RouteObserver {
  final RouterObserver _observer;

  GoRouteObserverAdapter(this._observer);

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _observer.onNavigationEvent(
      NavigationEvent(
        toRoute: route.settings.name,
        fromRoute: previousRoute?.settings.name,
      ),
    );
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    _observer.onNavigationEvent(
      NavigationEvent(
        toRoute: newRoute?.settings.name,
        fromRoute: oldRoute?.settings.name,
      ),
    );
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _observer.onNavigationEvent(
      NavigationEvent(
        fromRoute: route.settings.name,
        toRoute: previousRoute?.settings.name,
      ),
    );
  }
}

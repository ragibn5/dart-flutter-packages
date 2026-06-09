import 'package:app_template/router/navigation_event.dart';
import 'package:app_template/router/router_observer.dart';
import 'package:flutter/widgets.dart';

class GoRouteObserverAdapter extends NavigatorObserver {
  final RouterObserver _observer;

  GoRouteObserverAdapter(this._observer);

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _observer.onNavigationEvent(
      NavigationEvent(
        type: NavigationType.push,
        fromRoute: previousRoute?.settings.name,
        toRoute: route.settings.name ?? '',
      ),
    );
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    _observer.onNavigationEvent(
      NavigationEvent(
        type: NavigationType.replace,
        fromRoute: oldRoute?.settings.name,
        toRoute: newRoute?.settings.name ?? '',
      ),
    );
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _observer.onNavigationEvent(
      NavigationEvent(
        type: NavigationType.pop,
        fromRoute: route.settings.name,
        toRoute: previousRoute?.settings.name ?? '',
      ),
    );
  }
}

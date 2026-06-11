import 'package:auto_route/auto_route.dart';
import 'package:nav_router/src/models/navigation_event.dart';
import 'package:nav_router/src/services/router_observer.dart';

class AutoRouteObserverAdapter extends AutoRouteGuard {
  final RouterObserver _observer;

  AutoRouteObserverAdapter(this._observer);

  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) {
    _observer.onNavigationEvent(
      NavigationEvent(
        toRoute: resolver.routeName,
        fromRoute: router.current.name,
      ),
    );

    resolver.next();
  }
}

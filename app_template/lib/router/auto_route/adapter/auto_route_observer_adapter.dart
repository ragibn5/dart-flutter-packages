import 'package:app_template/router/navigation_event.dart';
import 'package:app_template/router/router_observer.dart';
import 'package:auto_route/auto_route.dart';

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

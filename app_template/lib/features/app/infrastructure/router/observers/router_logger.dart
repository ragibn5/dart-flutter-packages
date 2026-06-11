import 'package:nav_router/nav_router.dart';

class RouterLogger implements RouterObserver {
  @override
  void onNavigationEvent(NavigationEvent event) {
    print('Routing: ${event.fromRoute} -> ${event.toRoute}');
  }
}

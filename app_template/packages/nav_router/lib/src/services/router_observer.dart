import 'package:nav_router/src/models/navigation_event.dart';

abstract class RouterObserver {
  void onNavigationEvent(NavigationEvent event);
}

import 'package:app_template/router/navigation_event.dart';

abstract class RouterObserver {
  void onNavigationEvent(NavigationEvent event);
}

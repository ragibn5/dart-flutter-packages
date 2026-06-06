import 'package:app_logger/app_logger.dart';
import 'package:auto_route/auto_route.dart';
import 'package:meta/meta.dart';

class RouterLogger extends AutoRouteGuard {
  @visibleForTesting
  static const TAG = 'RouterLogger';

  final AppLogger _logger;

  RouterLogger(this._logger);

  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) {
    final currentRoute = router.current.name;
    final requestedRoute = resolver.routeName;
    _logger.logDebug(
      tag: TAG,
      message: buildLogMessage(currentRoute, requestedRoute),
    );
    resolver.next();
  }

  @visibleForTesting
  String buildLogMessage(String currentRoute, String requestedRoute) =>
      'Received navigation event: $currentRoute --> $requestedRoute';
}

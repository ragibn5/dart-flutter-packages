import 'package:app_logger/app_logger.dart';
import 'package:flutter/widgets.dart';

class RouterLogger extends NavigatorObserver {
  static const TAG = 'RouterLogger';

  final AppLogger _logger;

  RouterLogger(this._logger);

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _logger.logDebug(
      tag: TAG,
      message:
          'Received navigation event: '
          '${previousRoute?.settings.name ?? 'N/A'} --> ${route.settings.name}',
    );
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    _logger.logDebug(
      tag: TAG,
      message:
          'Received navigation event: '
          '${oldRoute?.settings.name ?? 'N/A'} --> ${newRoute?.settings.name}',
    );
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _logger.logDebug(
      tag: TAG,
      message:
          'Received navigation event: '
          '${route.settings.name} --> ${previousRoute?.settings.name ?? 'N/A'}',
    );
  }
}

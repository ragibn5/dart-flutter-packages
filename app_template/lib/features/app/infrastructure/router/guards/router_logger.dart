import 'package:app_logger/app_logger.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RouterLogger {
  final AppLogger _logger;

  RouterLogger(this._logger);

  /// Logs every navigation, and lets it through.
  Future<OnEnterResult> onEnter(
    BuildContext context,
    GoRouterState current,
    GoRouterState next,
    GoRouter router,
  ) async {
    _logger.logInfo(
      tag: '$RouterLogger',
      message: 'Routing: ${current.matchedLocation} -> ${next.matchedLocation}',
    );
    return const Allow();
  }
}

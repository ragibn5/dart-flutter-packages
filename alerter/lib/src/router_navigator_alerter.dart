import 'package:alerter/src/alerter.dart';
import 'package:flutter/material.dart';

class RouterNavigatorAlerter extends Alerter {
  final GlobalKey<NavigatorState> _navigatorKey;

  const RouterNavigatorAlerter(this._navigatorKey);

  @override
  BuildContext getCurrentContext() {
    final context = _navigatorKey.currentContext;
    if (context == null) {
      throw StateError(
        'Invalid navigator state, '
        'make sure you are using the same navigator key in your app.',
      );
    }

    return context;
  }
}

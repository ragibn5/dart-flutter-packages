import 'package:alerty/src/alerty.dart';
import 'package:flutter/material.dart';

class RouterNavigatorAlerty extends Alerty {
  final GlobalKey<NavigatorState> _navigatorKey;

  const RouterNavigatorAlerty(this._navigatorKey);

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

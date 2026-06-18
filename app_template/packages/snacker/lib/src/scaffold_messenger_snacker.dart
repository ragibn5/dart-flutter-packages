import 'package:flutter/material.dart';
import 'package:snacker/src/snacker.dart';

class ScaffoldMessengerSnacker extends Snacker {
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey;

  const ScaffoldMessengerSnacker(this._scaffoldMessengerKey);

  @override
  BuildContext getCurrentContext() {
    final context = _scaffoldMessengerKey.currentContext;
    if (context == null) {
      throw StateError(
        'Invalid scaffold messenger state, '
        'make sure you are using the same scaffold messenger key in your app.',
      );
    }

    return context;
  }
}

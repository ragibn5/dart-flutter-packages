import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:snacker/src/enums/snack_type.dart';
import 'package:snacker/src/models/snack_data.dart';
import 'package:snacker/src/snacker.dart';

class ScaffoldMessengerSnacker implements Snacker {
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey;

  const ScaffoldMessengerSnacker(this._scaffoldMessengerKey);

  @override
  void showTextSnack(SnackData data, {AnimationStyle? snackBarAnimationStyle}) {
    final currentState = _scaffoldMessengerKey.currentState;
    if (currentState == null) {
      throw StateError('No `$ScaffoldMessengerState` is available');
    }

    currentState
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: buildSnackBody(data),
          duration: data.duration,
          backgroundColor: getSnackBarBackgroundColor(data.snackType),
        ),
        snackBarAnimationStyle: snackBarAnimationStyle,
      );
  }

  @visibleForOverriding
  Text buildSnackBody(SnackData data) {
    return Text(
      data.message,
      textAlign: data.textAlignment,
      style: const TextStyle(color: Colors.white),
    );
  }

  @visibleForOverriding
  Color getSnackBarBackgroundColor(SnackType type) {
    switch (type) {
      case .INFO:
        return const Color(0xFF2196F3);
      case .SUCCESS:
        return const Color(0xFF4CAF50);
      case .WARNING:
        return const Color(0xFFFF9800);
      case .ERROR:
        return const Color(0xFFF44336);
    }
  }
}

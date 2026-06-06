import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:snacker/src/enums/snack_type.dart';
import 'package:snacker/src/models/snack_data.dart';

abstract class Snacker {
  const Snacker();

  void showTextSnack(SnackData data, {AnimationStyle? snackBarAnimationStyle}) {
    final currentState = getCurrentState();
    if (currentState == null) {
      throw StateError('No `$ScaffoldMessengerState` is available');
    }

    currentState
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(
            data.message,
            textAlign: data.textAlignment,
            style: const TextStyle(color: Colors.white),
          ),
          duration: data.duration,
          backgroundColor: getSnackBarBackgroundColor(data.snackType),
        ),
        snackBarAnimationStyle: snackBarAnimationStyle,
      );
  }

  @visibleForOverriding
  ScaffoldMessengerState? getCurrentState();

  @visibleForOverriding
  Color getSnackBarBackgroundColor(SnackType type);
}

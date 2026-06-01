import 'package:app_template/generated/assets/colors.gen.dart';
import 'package:app_template/shared/snacker/snack_data.dart';
import 'package:app_template/shared/snacker/snack_type.dart';
import 'package:app_template/shared/snacker/snacker.dart';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';

@Singleton(as: Snacker)
class ScaffoldMessengerBasedSnacker implements Snacker {
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerState;

  ScaffoldMessengerBasedSnacker(this._scaffoldMessengerState);

  @override
  void showTextSnack(SnackData data, {AnimationStyle? snackBarAnimationStyle}) {
    final currentState = _scaffoldMessengerState.currentState;
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
          backgroundColor: _getBackgroundColor(data.snackType),
        ),
        snackBarAnimationStyle: snackBarAnimationStyle,
      );
  }

  Color _getBackgroundColor(SnackType type) {
    switch (type) {
      case .INFO:
        return AppColors.snackBgInfo;
      case .SUCCESS:
        return AppColors.snackBgSuccess;
      case .WARNING:
        return AppColors.snackBgWarning;
      case .ERROR:
        return AppColors.snackBgError;
    }
  }
}

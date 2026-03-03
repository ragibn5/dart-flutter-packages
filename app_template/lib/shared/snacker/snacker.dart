import 'package:app_template/shared/snacker/snack_data.dart';
import 'package:flutter/material.dart';

abstract interface class Snacker {
  void showTextSnack(SnackData data, {AnimationStyle? snackBarAnimationStyle});
}

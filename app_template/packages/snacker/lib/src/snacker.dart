import 'package:flutter/material.dart';
import 'package:snacker/src/models/snack_data.dart';

abstract interface class Snacker {
  void showTextSnack(SnackData data, {AnimationStyle? snackBarAnimationStyle});
}

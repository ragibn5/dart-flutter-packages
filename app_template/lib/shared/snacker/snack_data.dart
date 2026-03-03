import 'package:app_template/shared/snacker/snack_type.dart';
import 'package:flutter/widgets.dart';

class SnackData {
  final String message;
  final Duration duration;
  final SnackType snackType;
  final TextAlign textAlignment;

  SnackData._({
    required this.message,
    required this.duration,
    required this.snackType,
    required this.textAlignment,
  });

  factory SnackData.info({
    required String message,
    Duration duration = const Duration(seconds: 2),
    TextAlign textAlignment = TextAlign.center,
  }) {
    return SnackData._(
      message: message,
      duration: duration,
      snackType: SnackType.INFO,
      textAlignment: textAlignment,
    );
  }

  factory SnackData.success({
    required String message,
    Duration duration = const Duration(seconds: 2),
    TextAlign textAlignment = TextAlign.center,
  }) {
    return SnackData._(
      message: message,
      duration: duration,
      snackType: SnackType.SUCCESS,
      textAlignment: textAlignment,
    );
  }

  factory SnackData.warning({
    required String message,
    Duration duration = const Duration(seconds: 2),
    TextAlign textAlignment = TextAlign.center,
  }) {
    return SnackData._(
      message: message,
      duration: duration,
      snackType: SnackType.WARNING,
      textAlignment: textAlignment,
    );
  }

  factory SnackData.error({
    required String message,
    Duration duration = const Duration(seconds: 2),
    TextAlign textAlignment = TextAlign.center,
  }) {
    return SnackData._(
      message: message,
      duration: duration,
      snackType: SnackType.ERROR,
      textAlignment: textAlignment,
    );
  }
}

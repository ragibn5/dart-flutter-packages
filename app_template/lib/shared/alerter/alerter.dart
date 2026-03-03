import 'package:app_template/shared/alerter/alert_data.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

abstract interface class Alerter {
  /// Show the alert
  Future<T?> showTextAlert<T>(AlertData<T> alertData);

  /// Build the alert UI with actions
  @visibleForOverriding
  AlertDialog buildAlertDialog<T>(BuildContext context, AlertData<T> alertData);
}

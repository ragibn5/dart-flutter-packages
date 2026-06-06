import 'package:alerter/src/models/alert_data.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

abstract class Alerter {
  const Alerter();

  Future<T?> showTextAlert<T>(AlertData<T> alertData) {
    return showDialog<T>(
      context: getCurrentContext(),
      builder: (context) => buildAlertDialog(context, alertData),
    );
  }

  @visibleForOverriding
  BuildContext getCurrentContext();

  @visibleForOverriding
  AlertDialog buildAlertDialog<T>(BuildContext context, AlertData<T> alertData);
}

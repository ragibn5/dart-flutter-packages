import 'package:alerter/src/alerter.dart';
import 'package:alerter/src/enums/alert_type.dart';
import 'package:alerter/src/models/alert_action.dart';
import 'package:alerter/src/models/alert_data.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class RouterNavigatorAlerter implements Alerter {
  final GlobalKey<NavigatorState> _navigatorKey;

  const RouterNavigatorAlerter(this._navigatorKey);

  @override
  Future<T?> showTextAlert<T>(AlertData<T> alertData) {
    return showDialog<T>(
      context: _getCurrentContext(),
      builder: (context) => _buildAlertDialog(context, alertData),
    );
  }

  @visibleForOverriding
  Widget? buildAlertTitle<T>(AlertData<T> alertData) {
    return Text(alertData.title);
  }

  @visibleForOverriding
  Widget? buildAlertIcon(AlertType type) {
    switch (type) {
      case .INFO:
        return const Icon(Icons.info);
      case .SUCCESS:
        return const Icon(Icons.check_circle);
      case .WARNING:
        return const Icon(Icons.warning);
      case .ERROR:
        return const Icon(Icons.error);
      case .PROMPT:
        return const Icon(Icons.question_mark_rounded);
    }
  }

  @visibleForOverriding
  Widget? buildAlertContent<T>(AlertData<T> alertData) {
    return SingleChildScrollView(child: Text(alertData.message));
  }

  @visibleForOverriding
  Widget buildActionButton(
    BuildContext context,
    String title,
    void Function() onTap,
  ) {
    return TextButton(onPressed: onTap, child: Text(title));
  }

  @visibleForOverriding
  EdgeInsetsGeometry? getActionsPadding() {
    return const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
  }

  Widget _buildAlertDialog<T>(BuildContext context, AlertData<T> alertData) {
    return AlertDialog(
      title: buildAlertTitle(alertData),
      icon: buildAlertIcon(alertData.alertType),
      content: buildAlertContent(alertData),
      actionsPadding: getActionsPadding(),
      actions: alertData.actions
          .map((e) => _buildActionButton(context, e))
          .toList(),
    );
  }

  Widget _buildActionButton<T>(BuildContext context, AlertAction<T> action) {
    switch (action) {
      case CloseAction():
        return buildActionButton(
          context,
          action.title,
          () => _tryPop(context, action.closingValue),
        );
      case PromptAction():
        return buildActionButton(
          context,
          action.title,
          () => _tryPop(context, action.onTap()),
        );
    }
  }

  BuildContext _getCurrentContext() {
    final context = _navigatorKey.currentContext;
    if (context == null) {
      throw StateError(
        'Invalid navigator state, '
        'make sure you are using the same navigator key in your app',
      );
    }

    return context;
  }

  void _tryPop<T>(BuildContext context, T data) {
    final capPop = Navigator.canPop(context);
    if (!capPop) {
      throw StateError(
        'Could not pop the alert due to invalid navigator state, '
        'make sure you are using the same navigator key in your app',
      );
    }

    Navigator.pop(context, data);
  }
}

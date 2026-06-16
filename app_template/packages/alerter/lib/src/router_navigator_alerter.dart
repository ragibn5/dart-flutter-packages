import 'package:alerter/src/alerter.dart';
import 'package:alerter/src/enums/alert_type.dart';
import 'package:alerter/src/models/alert_action.dart';
import 'package:alerter/src/models/alert_data.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class RouterNavigatorAlerter extends Alerter {
  final GlobalKey<NavigatorState> _navigatorKey;

  const RouterNavigatorAlerter(this._navigatorKey);

  @override
  BuildContext getCurrentContext() {
    final context = _navigatorKey.currentContext;
    if (context == null) {
      throw StateError(
        'Invalid navigator state, '
        'make sure you are using the same navigator key in your app',
      );
    }

    return context;
  }

  @override
  Widget buildAlertDialog<T>(BuildContext context, AlertData<T> alertData) {
    return AlertDialog(
      title: buildAlertTitle(alertData),
      icon: buildAlertIcon(alertData.alertType),
      actionsPadding: getActionsPadding(),
      content: buildAlertContent(alertData),
      actions: alertData.actions
          .map((e) => buildActionButton(context, e))
          .toList(),
    );
  }

  @visibleForOverriding
  Widget buildAlertTitle<T>(AlertData<T> alertData) {
    return Text(alertData.title);
  }

  @visibleForOverriding
  Widget buildAlertContent<T>(AlertData<T> alertData) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: 16,
      children: [Text(alertData.message)],
    );
  }

  @visibleForOverriding
  Widget buildAlertIcon(AlertType type) {
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
  Widget buildActionButton<T>(BuildContext context, AlertAction<T> action) {
    switch (action) {
      case CloseAction():
        return TextButton(
          onPressed: () => _tryPop(action.closingValue),
          child: Text(action.title),
        );
      case PromptAction():
        return TextButton(
          onPressed: () => _tryPop(action.onTap()),
          child: Text(action.title),
        );
    }
  }

  @visibleForOverriding
  EdgeInsetsGeometry? getActionsPadding() {
    return const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
  }

  void _tryPop<T>(T data) {
    final capPop = _navigatorKey.currentState?.canPop() ?? false;
    if (!capPop) {
      throw StateError(
        'Could not pop the alert due to invalid navigator state, '
        'make sure you are using the same navigator key in your app',
      );
    }

    _navigatorKey.currentState?.pop(data);
  }
}

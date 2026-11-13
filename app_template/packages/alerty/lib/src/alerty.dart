import 'package:alerty/src/models/alert_action.dart';
import 'package:alerty/src/models/alert_data.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

abstract class Alerty {
  const Alerty();

  /// Shows a text alert.
  ///
  /// Customize the appearance by overriding any of the `build*`
  /// methods (e.g., [buildAlertDialog], [buildAlertTitle] etc.).
  Future<T?> showTextAlert<T>(
    AlertData alertData,
    List<AlertAction<T>> actions,
  ) {
    return showDialog<T>(
      context: getCurrentContext(),
      builder: (context) => buildAlertDialog(
        alertData,
        actions
            .map((e) => buildActionButton(e.title, _handleAction(context, e)))
            .toList(),
      ),
    );
  }

  /// Provides the current context.
  ///
  /// This is used as the context on top of
  /// which our dialog is shown, or destroyed.
  @visibleForOverriding
  BuildContext getCurrentContext();

  /// Builds the root alert dialog widget.
  ///
  /// Params:
  /// - [alertData]: The data that you should use to build the dialog UI.
  /// - [actionButtons]: The corresponding action buttons for the actions
  ///   you provided with [showTextAlert]. Note that these buttons
  ///   automatically handles closing the dialog, and you don't need to,
  ///   or even shouldn't handle closing the dialog.
  ///
  /// Note:
  /// Override this method if you want to customize the entire dialog UI.
  /// But in case you want to customize only the components, you can do so
  /// by overriding any of the `build*` methods (e.g., [buildAlertDialog],
  /// [buildAlertTitle] etc.).
  @visibleForOverriding
  Widget buildAlertDialog(AlertData alertData, List<Widget> actionButtons) {
    return AlertDialog(
      title: buildAlertTitle(alertData),
      icon: buildAlertIcon(alertData),
      content: buildAlertContent(alertData),
      actionsPadding: getActionsPadding(),
      actions: actionButtons,
    );
  }

  /// Build the alert title widget.
  @visibleForOverriding
  Widget? buildAlertTitle(AlertData alertData) {
    return Text(alertData.title);
  }

  /// Build the alert icon widget.
  @visibleForOverriding
  Widget? buildAlertIcon(AlertData alertData) {
    switch (alertData.alertType) {
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

  /// Build the alert content (body) widget.
  @visibleForOverriding
  Widget? buildAlertContent(AlertData alertData) {
    return SingleChildScrollView(child: Text(alertData.message));
  }

  /// Build a single action button widget.
  ///
  /// Note: [onTap] already handles dialog dismissal —
  /// do not pop the dialog again inside it.
  @visibleForOverriding
  Widget buildActionButton(String title, void Function() onTap) {
    return TextButton(onPressed: onTap, child: Text(title));
  }

  /// The padding around the action buttons row.
  @visibleForOverriding
  EdgeInsetsGeometry? getActionsPadding() {
    return const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
  }

  void Function() _handleAction<T>(
    BuildContext context,
    AlertAction<T> action,
  ) {
    switch (action) {
      case CloseAction():
        return () => _tryPop(context, action.closingValue);
      case PromptAction():
        return () => _tryPop(context, action.onTap());
    }
  }

  void _tryPop<T>(BuildContext context, T data) {
    final capPop = Navigator.canPop(context);
    if (!capPop) {
      throw StateError(
        'Could not pop the alert due to invalid navigator state, '
        'make sure you are using the same navigator key in your app.',
      );
    }

    Navigator.pop(context, data);
  }
}

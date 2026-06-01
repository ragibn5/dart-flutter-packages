import 'package:app_template/shared/alerter/alert_action.dart';
import 'package:app_template/shared/alerter/alert_type.dart';

class AlertData<T> {
  final String title;
  final String message;
  final List<AlertAction<T>> actions;
  final AlertType alertType;

  AlertData._({
    required this.title,
    required this.message,
    required this.actions,
    required this.alertType,
  });

  factory AlertData.info({
    required String title,
    required String message,
    List<AlertAction<T>> actions = const [],
  }) {
    return AlertData._(
      title: title,
      message: message,
      actions: actions,
      alertType: .INFO,
    );
  }

  factory AlertData.success({
    required String title,
    required String message,
    List<AlertAction<T>> actions = const [],
  }) {
    return AlertData._(
      title: title,
      message: message,
      actions: actions,
      alertType: .SUCCESS,
    );
  }

  factory AlertData.warning({
    required String title,
    required String message,
    List<AlertAction<T>> actions = const [],
  }) {
    return AlertData._(
      title: title,
      message: message,
      actions: actions,
      alertType: .WARNING,
    );
  }

  factory AlertData.error({
    required String title,
    required String message,
    List<AlertAction<T>> actions = const [],
  }) {
    return AlertData._(
      title: title,
      message: message,
      actions: actions,
      alertType: .ERROR,
    );
  }

  factory AlertData.prompt({
    required String title,
    required String message,
    List<AlertAction<T>> actions = const [],
  }) {
    return AlertData._(
      title: title,
      message: message,
      actions: actions,
      alertType: .PROMPT,
    );
  }
}

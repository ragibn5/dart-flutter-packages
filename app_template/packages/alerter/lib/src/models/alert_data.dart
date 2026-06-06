import 'package:alerter/src/enums/alert_type.dart';
import 'package:alerter/src/models/alert_action.dart';

class AlertData<T> {
  final String title;
  final String message;
  final AlertType alertType;
  final List<AlertAction<T>> actions;

  AlertData._({
    required this.title,
    required this.message,
    required this.alertType,
    required this.actions,
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

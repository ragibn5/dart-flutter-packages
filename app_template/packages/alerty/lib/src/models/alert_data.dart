import 'package:alerty/src/enums/alert_type.dart';

class AlertData {
  final String title;
  final String message;
  final AlertType alertType;

  AlertData._({
    required this.title,
    required this.message,
    required this.alertType,
  });

  factory AlertData.info({required String title, required String message}) {
    return AlertData._(title: title, message: message, alertType: .INFO);
  }

  factory AlertData.success({required String title, required String message}) {
    return AlertData._(title: title, message: message, alertType: .SUCCESS);
  }

  factory AlertData.warning({required String title, required String message}) {
    return AlertData._(title: title, message: message, alertType: .WARNING);
  }

  factory AlertData.error({required String title, required String message}) {
    return AlertData._(title: title, message: message, alertType: .ERROR);
  }

  factory AlertData.prompt({required String title, required String message}) {
    return AlertData._(title: title, message: message, alertType: .PROMPT);
  }
}

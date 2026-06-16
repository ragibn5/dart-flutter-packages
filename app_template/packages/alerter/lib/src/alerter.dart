import 'package:alerter/src/models/alert_data.dart';

abstract interface class Alerter {
  Future<T?> showTextAlert<T>(AlertData<T> alertData);
}

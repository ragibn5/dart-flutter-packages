import 'package:app_template/core/contracts/initializable.dart';

abstract interface class CrashlyticsService implements Initializable {
  Future<void> setSessionData(String userId, {required bool collectionEnabled});

  Future<void> recordError(
    dynamic exception,
    StackTrace? stackTrace, {
    dynamic reason,
    bool? printDetails,
    bool fatal = false,
  });
}

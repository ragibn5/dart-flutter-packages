import 'package:app_template/core/contracts/initializable.dart';

abstract interface class AnalyticsService implements Initializable {
  Future<void> setSessionData(String userId, {required bool collectionEnabled});

  Future<void> setUserProperty({required String name, required String value});

  Future<void> logEvent(String name, [Map<String, Object>? params]);
}

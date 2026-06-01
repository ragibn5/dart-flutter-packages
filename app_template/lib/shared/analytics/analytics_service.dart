import 'package:initializable/initializable.dart';

abstract interface class AnalyticsService implements Initializable {
  Future<void> setSessionData(String userId, {required bool collectionEnabled});

  Future<void> logEvent(String name, [Map<String, Object>? params]);
}

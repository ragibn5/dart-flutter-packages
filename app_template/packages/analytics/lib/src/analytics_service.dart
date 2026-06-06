import 'package:initializable/initializable.dart';
import 'package:meta/meta.dart';

abstract class AnalyticsService implements Initializable {
  const AnalyticsService();

  @mustCallSuper
  @override
  Future<void> initialize() async {}

  Future<void> setSessionData(String userId, {required bool collectionEnabled});

  Future<void> logEvent(String name, [Map<String, Object>? params]);
}

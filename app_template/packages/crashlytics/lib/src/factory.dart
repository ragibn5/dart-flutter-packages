import 'package:crashlytics/src/crashlytics_service.dart';
import 'package:crashlytics/src/firebase_crashlytics_service.dart';

class CrashlyticsServiceFactory {
  const CrashlyticsServiceFactory();

  CrashlyticsService create() => FirebaseCrashlyticsService();
}

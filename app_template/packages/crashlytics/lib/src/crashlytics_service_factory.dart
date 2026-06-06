import 'package:crashlytics/src/crashlytics_service.dart';
import 'package:crashlytics/src/firebase_crashlytics_service.dart';

/// Creates [CrashlyticsService] instances.
class CrashlyticsServiceFactory {
  const CrashlyticsServiceFactory();

  /// Creates a new [CrashlyticsService].
  CrashlyticsService create() => FirebaseCrashlyticsService();
}

import 'package:analytics/src/analytics_service.dart';
import 'package:analytics/src/firebase_analytics_service.dart';

/// Creates [AnalyticsService] instances.
class AnalyticsServiceFactory {
  const AnalyticsServiceFactory();

  /// Creates a new [AnalyticsService].
  AnalyticsService create() => FirebaseAnalyticsService();
}

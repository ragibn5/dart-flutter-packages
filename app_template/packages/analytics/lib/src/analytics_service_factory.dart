import 'package:analytics/src/analytics_service.dart';
import 'package:analytics/src/firebase_analytics_service.dart';

class AnalyticsServiceFactory {
  const AnalyticsServiceFactory();

  AnalyticsService create() => FirebaseAnalyticsService();
}

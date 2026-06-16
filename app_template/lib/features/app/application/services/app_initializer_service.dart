import 'package:analytics/analytics.dart';
import 'package:crashlytics/crashlytics.dart';
import 'package:initializable/initializable.dart';
import 'package:sqlite_db/sqlite_db.dart';

class AppInitializerService extends InitializerPipeline {
  AppInitializerService(
    CrashlyticsService crashlyticsService,
    AnalyticsService analyticsService,
    SQLiteDb appDatabase,
  ) : super([crashlyticsService, analyticsService, appDatabase]);
}

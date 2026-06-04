import 'package:app_template/features/app/application/services/app_initializer_service.dart';
import 'package:app_template/shared/analytics/analytics_service.dart';
import 'package:app_template/shared/crashlytics/crashlytics_service.dart';
import 'package:sqlite_db/sqlite_db.dart';

class AppInitializerServiceImpl extends AppInitializerService {
  AppInitializerServiceImpl(
    CrashlyticsService crashlyticsService,
    AnalyticsService analyticsService,
    SQLiteDb appDatabase,
  ) : super([crashlyticsService, analyticsService, appDatabase]);
}

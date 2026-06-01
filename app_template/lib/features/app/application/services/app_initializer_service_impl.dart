import 'package:app_template/core/infrastructure/storage/database/sqlite_db.dart';
import 'package:app_template/features/app/application/services/app_initializer_service.dart';
import 'package:app_template/shared/analytics/analytics_service.dart';
import 'package:app_template/shared/crashlytics/crashlytics_service.dart';

class AppInitializerServiceImpl extends AppInitializerService {
  AppInitializerServiceImpl(
    CrashlyticsService crashlyticsService,
    AnalyticsService analyticsService,
    SQLiteDb appDatabase,
  ) : super([crashlyticsService, analyticsService, appDatabase]);
}

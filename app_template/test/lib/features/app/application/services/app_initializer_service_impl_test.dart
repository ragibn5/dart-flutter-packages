import 'package:app_template/features/app/application/services/app_initializer_service_impl.dart';
import 'package:app_template/shared/analytics/analytics_service.dart';
import 'package:app_template/shared/crashlytics/crashlytics_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sqlite_db/sqlite_db.dart';

class _MockCrashlyticsService extends Mock implements CrashlyticsService {}

class _MockAnalyticsService extends Mock implements AnalyticsService {}

class _MockSQLiteDb extends Mock implements SQLiteDb {}

void main() {
  late _MockCrashlyticsService mockCrashlytics;
  late _MockAnalyticsService mockAnalytics;
  late _MockSQLiteDb mockDatabase;

  late AppInitializerServiceImpl sut;

  setUp(() {
    mockCrashlytics = _MockCrashlyticsService();
    mockAnalytics = _MockAnalyticsService();
    mockDatabase = _MockSQLiteDb();

    sut = AppInitializerServiceImpl(
      mockCrashlytics,
      mockAnalytics,
      mockDatabase,
    );
  });

  test('Should initialize all services in order', () async {
    await sut.initialize();

    verifyInOrder([
      () => mockCrashlytics.initialize(),
      () => mockAnalytics.initialize(),
      () => mockDatabase.initialize(),
    ]);
  });
}

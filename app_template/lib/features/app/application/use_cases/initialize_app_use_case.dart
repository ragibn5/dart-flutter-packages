import 'package:analytics/analytics.dart';
import 'package:crashlytics/crashlytics.dart';
import 'package:sqlite_db/sqlite_db.dart';

class InitializeAppUseCase {
  final CrashlyticsService _crashlyticsService;
  final AnalyticsService _analyticsService;
  final SQLiteDb _appDatabase;

  InitializeAppUseCase(
    this._crashlyticsService,
    this._analyticsService,
    this._appDatabase,
  );

  /// Initializes the app.
  Future<void> call() async {
    final initializables = [
      _crashlyticsService,
      _analyticsService,
      _appDatabase,
    ];
    for (final initializable in initializables) {
      await initializable.initialize();
    }
  }
}

import 'package:analytics/analytics.dart';
import 'package:app_template/features/auth/domain/services/auth_data_service.dart';
import 'package:crashlytics/crashlytics.dart';
import 'package:initializable/initializable.dart';
import 'package:meta/meta.dart';

class SessionInitializerService implements Initializable {
  final String _anonymousUserId;

  final AuthDataService _authDataService;
  final AnalyticsService _analyticsService;
  final CrashlyticsService _crashlyticsService;

  SessionInitializerService(
    AuthDataService authDataService,
    AnalyticsService analyticsService,
    CrashlyticsService crashlyticsService,
  ) : this._(
        'anonymous',
        authDataService,
        analyticsService,
        crashlyticsService,
      );

  @visibleForTesting
  SessionInitializerService.test(
    AuthDataService authDataService,
    AnalyticsService analyticsService,
    CrashlyticsService crashlyticsService, {
    required String anonymousUserId,
  }) : this._(
         anonymousUserId,
         authDataService,
         analyticsService,
         crashlyticsService,
       );

  SessionInitializerService._(
    this._anonymousUserId,
    this._authDataService,
    this._analyticsService,
    this._crashlyticsService,
  );

  @override
  Future<void> initialize() async {
    final authData = await _authDataService.getCurrentAuthData();

    await _analyticsService.setSessionData(
      authData != null ? authData.userId : _anonymousUserId,
      collectionEnabled: true,
    );

    await _crashlyticsService.setSessionData(
      authData != null ? authData.userId : _anonymousUserId,
      collectionEnabled: true,
    );
  }
}

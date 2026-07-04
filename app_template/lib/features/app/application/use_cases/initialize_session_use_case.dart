import 'package:app_template/features/app/application/use_cases/get_user_id_use_case.dart';
import 'package:app_template/features/app/application/use_cases/set_analytics_session_data_use_case.dart';
import 'package:app_template/features/app/application/use_cases/set_crashlytics_session_data_use_case.dart';

/// Initializes the session.
class InitializeSessionUseCase {
  final String _anonymousUserId;

  final GetUserIdUseCase _getUserId;
  final SetAnalyticsSessionDataUseCase _setAnalyticsSessionData;
  final SetCrashlyticsSessionDataUseCase _setCrashlyticsSessionData;

  InitializeSessionUseCase(
    this._getUserId,
    this._setAnalyticsSessionData,
    this._setCrashlyticsSessionData, {
    String anonymousUserId = 'anonymous',
  }) : _anonymousUserId = anonymousUserId;

  Future<void> call() async {
    final userId = await _getUserId();

    await _setAnalyticsSessionData(
      userId ?? _anonymousUserId,
      collectionEnabled: true,
    );

    await _setCrashlyticsSessionData(
      userId ?? _anonymousUserId,
      collectionEnabled: true,
    );
  }
}

import 'package:app_template/features/app/application/ports/get_user_id_port.dart';
import 'package:app_template/features/app/application/ports/set_analytics_session_data_port.dart';
import 'package:app_template/features/app/application/ports/set_crashlytics_session_data_port.dart';

class InitializeSessionUseCase {
  final String _anonymousUserId;

  final GetUserIdPort _getUserId;
  final SetAnalyticsSessionDataPort _setAnalyticsSessionData;
  final SetCrashlyticsSessionDataPort _setCrashlyticsSessionData;

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

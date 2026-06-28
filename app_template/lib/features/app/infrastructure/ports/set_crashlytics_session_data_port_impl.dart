import 'package:app_template/features/app/application/ports/set_crashlytics_session_data_port.dart';
import 'package:crashlytics/crashlytics.dart';

class SetCrashlyticsSessionDataPortImpl
    implements SetCrashlyticsSessionDataPort {
  final CrashlyticsService _crashlyticsService;

  SetCrashlyticsSessionDataPortImpl(this._crashlyticsService);

  @override
  Future<void> call(String userId, {required bool collectionEnabled}) {
    return _crashlyticsService.setSessionData(
      userId,
      collectionEnabled: collectionEnabled,
    );
  }
}

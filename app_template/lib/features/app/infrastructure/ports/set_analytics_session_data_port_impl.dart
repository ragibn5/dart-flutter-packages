import 'package:analytics/analytics.dart';
import 'package:app_template/features/app/application/ports/set_analytics_session_data_port.dart';

class SetAnalyticsSessionDataPortImpl implements SetAnalyticsSessionDataPort {
  final AnalyticsService _analyticsService;

  SetAnalyticsSessionDataPortImpl(this._analyticsService);

  @override
  Future<void> call(String userId, {required bool collectionEnabled}) {
    return _analyticsService.setSessionData(
      userId,
      collectionEnabled: collectionEnabled,
    );
  }
}

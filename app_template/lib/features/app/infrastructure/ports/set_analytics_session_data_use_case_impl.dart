import 'package:analykit/analykit.dart';
import 'package:app_template/features/app/application/use_cases/set_analytics_session_data_use_case.dart';

class SetAnalyticsSessionDataUseCaseImpl
    implements SetAnalyticsSessionDataUseCase {
  final AnalyticsService _analyticsService;

  SetAnalyticsSessionDataUseCaseImpl(this._analyticsService);

  @override
  Future<void> call(String userId, {required bool collectionEnabled}) async {
    await _analyticsService.setUserId(userId);
    await _analyticsService.setCollectionEnabled(enabled: collectionEnabled);
  }
}

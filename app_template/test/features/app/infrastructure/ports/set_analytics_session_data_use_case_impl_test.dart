import 'package:analykit/analykit.dart';
import 'package:app_template/features/app/infrastructure/ports/set_analytics_session_data_use_case_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockAnalyticsService extends Mock implements AnalyticsService {}

void main() {
  late _MockAnalyticsService mockAnalyticsService;

  late SetAnalyticsSessionDataUseCaseImpl sut;

  setUp(() {
    mockAnalyticsService = _MockAnalyticsService();

    sut = SetAnalyticsSessionDataUseCaseImpl(mockAnalyticsService);

    when(() => mockAnalyticsService.setUserId(any())).thenAnswer((_) async {});
    when(
      () => mockAnalyticsService.setCollectionEnabled(
        enabled: any(named: 'enabled'),
      ),
    ).thenAnswer((_) async {});
  });

  test('Should set the user ID and the collection choice', () async {
    await sut('test-user', collectionEnabled: true);

    verify(() => mockAnalyticsService.setUserId('test-user')).called(1);
    verify(
      () => mockAnalyticsService.setCollectionEnabled(enabled: true),
    ).called(1);
  });
}

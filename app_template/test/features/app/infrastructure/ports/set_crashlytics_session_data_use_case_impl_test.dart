import 'package:app_template/features/app/infrastructure/ports/set_crashlytics_session_data_use_case_impl.dart';
import 'package:crashlykit/crashlykit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockCrashlyticsService extends Mock implements CrashlyticsService {}

void main() {
  late _MockCrashlyticsService mockCrashlyticsService;

  late SetCrashlyticsSessionDataUseCaseImpl sut;

  setUp(() {
    mockCrashlyticsService = _MockCrashlyticsService();

    sut = SetCrashlyticsSessionDataUseCaseImpl(mockCrashlyticsService);

    when(
      () => mockCrashlyticsService.setUserId(any()),
    ).thenAnswer((_) async {});
    when(
      () => mockCrashlyticsService.setCollectionEnabled(
        enabled: any(named: 'enabled'),
      ),
    ).thenAnswer((_) async {});
  });

  test('Should set the user ID and the collection choice', () async {
    await sut('test-user', collectionEnabled: true);

    verify(() => mockCrashlyticsService.setUserId('test-user')).called(1);
    verify(
      () => mockCrashlyticsService.setCollectionEnabled(enabled: true),
    ).called(1);
  });
}

// ignore_for_file: lines_longer_than_80_chars

import 'package:app_template/features/app/application/use_cases/get_user_id_use_case.dart';
import 'package:app_template/features/app/application/use_cases/initialize_session_use_case.dart';
import 'package:app_template/features/app/application/use_cases/set_analytics_session_data_use_case.dart';
import 'package:app_template/features/app/application/use_cases/set_crashlytics_session_data_use_case.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockGetUserIdUseCase extends Mock implements GetUserIdUseCase {}

class _MockSetAnalyticsSessionDataUseCase extends Mock
    implements SetAnalyticsSessionDataUseCase {}

class _MockSetCrashlyticsSessionDataUseCase extends Mock
    implements SetCrashlyticsSessionDataUseCase {}

void main() {
  const anonymousUserId = 'anonymous-user';

  late _MockGetUserIdUseCase mockGetUserId;
  late _MockSetAnalyticsSessionDataUseCase mockSetAnalyticsSessionData;
  late _MockSetCrashlyticsSessionDataUseCase mockSetCrashlyticsSessionData;

  late InitializeSessionUseCase sut;

  setUp(() {
    mockGetUserId = _MockGetUserIdUseCase();
    mockSetAnalyticsSessionData = _MockSetAnalyticsSessionDataUseCase();
    mockSetCrashlyticsSessionData = _MockSetCrashlyticsSessionDataUseCase();

    sut = InitializeSessionUseCase(
      mockGetUserId,
      mockSetAnalyticsSessionData,
      mockSetCrashlyticsSessionData,
      anonymousUserId: anonymousUserId,
    );

    when(
      () => mockSetAnalyticsSessionData.call(
        any(),
        collectionEnabled: any(named: 'collectionEnabled'),
      ),
    ).thenAnswer((_) async {});
    when(
      () => mockSetCrashlyticsSessionData.call(
        any(),
        collectionEnabled: any(named: 'collectionEnabled'),
      ),
    ).thenAnswer((_) async {});
  });

  test('Should set correct user id if user id is not null', () async {
    when(() => mockGetUserId()).thenAnswer((_) async => 'userId');

    await sut();

    verify(
      () => mockSetAnalyticsSessionData('userId', collectionEnabled: true),
    );
    verify(
      () => mockSetCrashlyticsSessionData('userId', collectionEnabled: true),
    );
  });

  test('Should set anonymous user if user id is null', () async {
    when(() => mockGetUserId()).thenAnswer((_) async => null);

    await sut();

    verify(
      () =>
          mockSetAnalyticsSessionData(anonymousUserId, collectionEnabled: true),
    );
    verify(
      () => mockSetCrashlyticsSessionData(
        anonymousUserId,
        collectionEnabled: true,
      ),
    );
  });
}

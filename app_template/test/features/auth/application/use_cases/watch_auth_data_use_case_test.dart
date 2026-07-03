import 'dart:async';

import 'package:app_template/features/auth/application/use_cases/watch_auth_data_use_case.dart';
import 'package:app_template/features/auth/domain/models/auth_data.dart';
import 'package:app_template/features/auth/domain/repositories/auth_data_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockAuthDataRepository extends Mock implements AuthDataRepository {}

void main() {
  final authData = AuthData(
    userId: 'userId',
    accessToken: 'accessToken',
    refreshToken: 'refreshToken',
    accessTokenExpiry: DateTime.now(),
    refreshTokenExpiry: DateTime.now(),
  );

  late _MockAuthDataRepository mockRepository;

  late WatchAuthDataUseCase sut;

  setUp(() {
    mockRepository = _MockAuthDataRepository();

    sut = WatchAuthDataUseCase(mockRepository);
  });

  test('Should return stream from repository', () async {
    final expectedStream = Stream.fromIterable([authData, null]);
    when(
      () => mockRepository.getAuthDataStream(),
    ).thenAnswer((_) => expectedStream);

    final result = sut();

    expect(result, expectedStream);
  });
}

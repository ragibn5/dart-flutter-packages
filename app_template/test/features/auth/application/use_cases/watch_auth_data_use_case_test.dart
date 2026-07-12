import 'dart:async';

import 'package:app_template/features/auth/application/use_cases/watch_auth_data_use_case.dart';
import 'package:app_template/features/auth/domain/repositories/auth_data_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockAuthDataRepository extends Mock implements AuthDataRepository {}

void main() {
  late _MockAuthDataRepository mockRepository;

  late WatchAuthDataUseCase sut;

  setUp(() {
    mockRepository = _MockAuthDataRepository();

    sut = WatchAuthDataUseCase(mockRepository);
  });

  test('Should call repository.getAuthDataStream', () {
    when(
      () => mockRepository.getAuthDataStream(),
    ).thenAnswer((_) => const Stream.empty());

    sut();

    verify(() => mockRepository.getAuthDataStream()).called(1);
  });
}

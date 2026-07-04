import 'dart:async';

import 'package:app_template/features/app/application/use_cases/watch_settings_use_case.dart';
import 'package:app_template/features/app/domain/repositories/settings_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockSettingsRepository extends Mock implements SettingsRepository {}

void main() {
  late _MockSettingsRepository mockSettingsRepository;

  late WatchSettingsUseCase sut;

  setUp(() {
    mockSettingsRepository = _MockSettingsRepository();

    sut = WatchSettingsUseCase(mockSettingsRepository);
  });

  test('Should call repository.getSettingsStream', () {
    when(
      () => mockSettingsRepository.getSettingsStream(),
    ).thenAnswer((_) => const Stream.empty());

    sut();

    verify(() => mockSettingsRepository.getSettingsStream()).called(1);
  });
}

import 'package:app_template/features/app/application/use_cases/get_settings_use_case.dart';
import 'package:app_template/features/app/domain/models/app_settings.dart';
import 'package:app_template/features/app/domain/repositories/settings_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockSettingsRepository extends Mock implements SettingsRepository {}

void main() {
  late _MockSettingsRepository mockSettingsRepository;

  late GetSettingsUseCase sut;

  setUp(() {
    mockSettingsRepository = _MockSettingsRepository();

    sut = GetSettingsUseCase(mockSettingsRepository);

    when(
      () => mockSettingsRepository.getCurrentSettings(),
    ).thenAnswer((_) async => const AppSettings());
  });

  test('Should call repo.getCurrentSettings', () async {
    await sut();

    verify(() => mockSettingsRepository.getCurrentSettings()).called(1);
  });
}

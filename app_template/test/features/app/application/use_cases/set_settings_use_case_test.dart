import 'package:app_template/features/app/application/use_cases/set_settings_use_case.dart';
import 'package:app_template/features/app/domain/models/app_settings.dart';
import 'package:app_template/features/app/domain/repositories/settings_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockSettingsRepository extends Mock implements SettingsRepository {}

void main() {
  late _MockSettingsRepository mockSettingsRepository;

  late SetSettingsUseCase sut;

  setUpAll(() {
    registerFallbackValue(const AppSettings());
  });

  setUp(() {
    mockSettingsRepository = _MockSettingsRepository();

    sut = SetSettingsUseCase(mockSettingsRepository);

    when(
      () => mockSettingsRepository.setCurrentSettings(any()),
    ).thenAnswer((_) async {});
  });

  test('Should call repo.setCurrentSettings with given settings', () async {
    const appSettings = AppSettings();

    await sut(appSettings);

    verify(() => mockSettingsRepository.setCurrentSettings(appSettings));
  });
}

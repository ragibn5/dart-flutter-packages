import 'package:app_template/features/app/application/use_cases/get_locale_use_case.dart';
import 'package:app_template/features/app/domain/entities/app_locale.dart';
import 'package:app_template/features/app/domain/entities/app_settings.dart';
import 'package:app_template/features/app/domain/repositories/settings_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockSettingsRepository extends Mock implements SettingsRepository {}

void main() {
  late _MockSettingsRepository mockSettingsRepository;

  late GetLocaleUseCase sut;

  setUpAll(() {
    registerFallbackValue(const AppSettings());
  });

  setUp(() {
    mockSettingsRepository = _MockSettingsRepository();

    sut = GetLocaleUseCase(mockSettingsRepository);

    when(
      () => mockSettingsRepository.getCurrentSettings(),
    ).thenAnswer((_) async => const AppSettings());
  });

  test('Should return persisted locale when available', () async {
    when(
      () => mockSettingsRepository.getCurrentSettings(),
    ).thenAnswer((_) async => const AppSettings(locale: AppLocale.EN));

    final result = await sut();

    expect(result, AppLocale.EN);
  });

  test('Should return SYSTEM when no locale is persisted', () async {
    final result = await sut();

    expect(result, AppLocale.SYSTEM);
  });
}

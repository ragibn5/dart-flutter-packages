import 'package:app_template/features/app/application/use_cases/get_effective_theme_mode_use_case.dart';
import 'package:app_template/features/app/application/use_cases/get_theme_mode_use_case.dart';
import 'package:app_template/features/app/domain/entities/app_theme_mode.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockGetThemeModeUseCase extends Mock implements GetThemeModeUseCase {}

void main() {
  late _MockGetThemeModeUseCase mockGetThemeModeUseCase;

  late GetEffectiveThemeModeUseCase sut;

  setUp(() {
    mockGetThemeModeUseCase = _MockGetThemeModeUseCase();

    sut = GetEffectiveThemeModeUseCase(mockGetThemeModeUseCase);
  });

  test('Should return persisted theme mode from GetThemeModeUseCase', () async {
    when(
      () => mockGetThemeModeUseCase(),
    ).thenAnswer((_) async => AppThemeMode.DARK);

    final result = await sut();

    expect(result, AppThemeMode.DARK);
  });

  test(
    'Should return SYSTEM when GetThemeModeUseCase returns SYSTEM',
    () async {
      when(
        () => mockGetThemeModeUseCase(),
      ).thenAnswer((_) async => AppThemeMode.SYSTEM);

      final result = await sut();

      expect(result, AppThemeMode.SYSTEM);
    },
  );
}

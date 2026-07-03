import 'package:app_template/features/app/domain/entities/locale_components.dart';
import 'package:app_template/features/app/infrastructure/ports/get_platform_locale_use_case.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Should return LocaleComponents obtained from platform locale', (
    tester,
  ) async {
    final sut = GetPlatformLocaleUseCaseImpl(tester.binding);

    final result = await sut();

    expect(result, isA<LocaleComponents>());
    expect(result.languageCode, isNotEmpty);
  });
}

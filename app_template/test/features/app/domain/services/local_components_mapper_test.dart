import 'package:app_template/features/app/domain/models/app_locale.dart';
import 'package:app_template/features/app/domain/models/locale_components.dart';
import 'package:app_template/features/app/domain/services/local_components_mapper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late LocalComponentsMapper sut;

  setUp(() {
    sut = LocalComponentsMapper();
  });

  test('Should map each AppLocale to correct LocaleComponents', () {
    for (final appLocale in AppLocale.values) {
      final result = sut.mapLocaleComponents(appLocale);

      expect(
        result,
        LocaleComponents(
          languageCode: appLocale.languageCode,
          scriptCode: appLocale.scriptCode,
          countryCode: appLocale.countryCode,
        ),
      );
    }
  });
}

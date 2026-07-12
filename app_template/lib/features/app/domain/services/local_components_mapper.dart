import 'package:app_template/features/app/domain/models/app_locale.dart';
import 'package:app_template/features/app/domain/models/locale_components.dart';

class LocalComponentsMapper {
  /// Maps an [AppLocale] into a [LocaleComponents].
  LocaleComponents mapLocaleComponents(AppLocale appLocale) {
    return LocaleComponents(
      languageCode: appLocale.languageCode,
      countryCode: appLocale.countryCode,
      scriptCode: appLocale.scriptCode,
    );
  }
}

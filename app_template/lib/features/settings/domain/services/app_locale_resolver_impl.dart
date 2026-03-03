import 'package:app_template/features/settings/domain/models/app_locale.dart';
import 'package:app_template/features/settings/domain/models/locale_components.dart';
import 'package:app_template/features/settings/domain/services/app_locale_resolver.dart';

class AppLocaleResolverImpl implements AppLocaleResolver {
  @override
  AppLocale? resolveLocale(LocaleComponents requested) {
    bool match(AppLocale locale, {bool script = false, bool country = false}) {
      if (locale.languageCode != requested.languageCode) return false;
      if (script && locale.scriptCode != requested.scriptCode) return false;
      if (country && locale.countryCode != requested.countryCode) return false;
      return true;
    }

    // 1️⃣ language + script + country
    for (final locale in AppLocale.values) {
      if (match(locale, script: true, country: true)) return locale;
    }

    // 2️⃣ language + script
    if (requested.scriptCode != null) {
      for (final locale in AppLocale.values) {
        if (match(locale, script: true)) return locale;
      }
    }

    // 3️⃣ language + country
    if (requested.countryCode != null) {
      for (final locale in AppLocale.values) {
        if (match(locale, country: true)) return locale;
      }
    }

    // 4️⃣ language only
    for (final locale in AppLocale.values) {
      if (match(locale)) return locale;
    }

    return null;
  }
}

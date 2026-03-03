import 'package:app_template/features/settings/domain/models/app_locale.dart';
import 'package:app_template/features/settings/domain/models/locale_components.dart';

abstract interface class AppLocaleResolver {
  AppLocale? resolveLocale(LocaleComponents requested);
}

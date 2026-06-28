import 'package:app_template/features/settings/domain/entities/locale_components.dart';

abstract interface class PlatformSettingsProvider {
  LocaleComponents getSystemaLocale();
}

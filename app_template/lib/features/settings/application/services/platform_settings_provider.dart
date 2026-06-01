import 'package:app_template/features/settings/domain/models/locale_components.dart';

abstract interface class PlatformSettingsProvider {
  LocaleComponents getSystemaLocale();
}

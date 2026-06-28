import 'package:app_template/features/settings/application/services/platform_settings_provider.dart';
import 'package:app_template/features/settings/domain/entities/locale_components.dart';
import 'package:flutter/widgets.dart';

class PlatformSettingsProviderImpl implements PlatformSettingsProvider {
  final WidgetsBinding _binding;

  PlatformSettingsProviderImpl(this._binding);

  @override
  LocaleComponents getSystemaLocale() {
    final systemLocale = _binding.platformDispatcher.locale;
    return LocaleComponents(
      languageCode: systemLocale.languageCode,
      scriptCode: systemLocale.scriptCode,
      countryCode: systemLocale.countryCode,
    );
  }
}

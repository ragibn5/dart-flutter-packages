import 'package:app_template/features/settings/application/use_cases/get_platform_locale_use_case.dart';
import 'package:app_template/features/settings/domain/entities/locale_components.dart';
import 'package:flutter/widgets.dart';

class GetPlatformLocaleUseCaseImpl implements GetPlatformLocaleUseCase {
  final WidgetsBinding _binding;

  GetPlatformLocaleUseCaseImpl(this._binding);

  @override
  Future<LocaleComponents> call() async {
    final systemLocale = _binding.platformDispatcher.locale;
    return LocaleComponents(
      languageCode: systemLocale.languageCode,
      scriptCode: systemLocale.scriptCode,
      countryCode: systemLocale.countryCode,
    );
  }
}

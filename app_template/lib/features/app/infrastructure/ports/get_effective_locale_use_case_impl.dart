import 'package:app_template/features/app/application/use_cases/get_effective_locale_use_case.dart';
import 'package:app_template/features/settings/application/services/settings_service.dart';
import 'package:app_template/features/settings/domain/entities/app_locale.dart';

class GetEffectiveLocaleUseCaseImpl implements GetEffectiveLocaleUseCase {
  final SettingsService _settingsService;

  GetEffectiveLocaleUseCaseImpl(this._settingsService);

  @override
  Future<AppLocale> call() {
    return _settingsService.getEffectiveLocale();
  }
}

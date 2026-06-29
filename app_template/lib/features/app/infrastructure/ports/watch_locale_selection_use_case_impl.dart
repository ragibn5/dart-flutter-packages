import 'package:app_template/features/app/application/use_cases/watch_locale_selection_use_case.dart';
import 'package:app_template/features/settings/application/services/settings_service.dart';
import 'package:app_template/features/settings/domain/entities/app_locale.dart';

class WatchLocaleSelectionUseCaseImpl implements WatchLocaleSelectionUseCase {
  final SettingsService _settingsService;

  WatchLocaleSelectionUseCaseImpl(this._settingsService);

  @override
  Stream<AppLocale> call() {
    return _settingsService.watchLocale();
  }
}

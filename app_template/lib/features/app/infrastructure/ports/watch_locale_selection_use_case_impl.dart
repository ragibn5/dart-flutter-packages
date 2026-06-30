import 'package:app_template/features/app/application/use_cases/watch_locale_selection_use_case.dart';
import 'package:app_template/features/settings/application/use_cases/watch_locale_use_case.dart'
    as settings;
import 'package:app_template/features/settings/domain/entities/app_locale.dart';

class WatchLocaleSelectionUseCaseImpl implements WatchLocaleSelectionUseCase {
  final settings.WatchLocaleUseCase _watchLocale;

  WatchLocaleSelectionUseCaseImpl(this._watchLocale);

  @override
  Stream<AppLocale> call() {
    return _watchLocale();
  }
}

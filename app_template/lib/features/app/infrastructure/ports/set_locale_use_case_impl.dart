import 'package:app_template/features/app/application/use_cases/set_locale_use_case.dart';
import 'package:app_template/features/settings/application/use_cases/set_locale_use_case.dart'
    as settings;
import 'package:app_template/features/settings/domain/entities/app_locale.dart';

class SetLocaleUseCaseImpl implements SetLocaleUseCase {
  final settings.SetLocaleUseCase _setLocale;

  SetLocaleUseCaseImpl(this._setLocale);

  @override
  Future<void> call(AppLocale locale) {
    return _setLocale(locale);
  }
}

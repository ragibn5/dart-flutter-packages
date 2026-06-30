import 'package:app_template/features/app/application/use_cases/get_effective_locale_use_case.dart';
import 'package:app_template/features/settings/application/use_cases/get_effective_locale_use_case.dart'
    as settings;
import 'package:app_template/features/settings/domain/entities/app_locale.dart';

class GetEffectiveLocaleUseCaseImpl implements GetEffectiveLocaleUseCase {
  final settings.GetEffectiveLocaleUseCase _getEffectiveLocale;

  GetEffectiveLocaleUseCaseImpl(this._getEffectiveLocale);

  @override
  Future<AppLocale> call() {
    return _getEffectiveLocale();
  }
}

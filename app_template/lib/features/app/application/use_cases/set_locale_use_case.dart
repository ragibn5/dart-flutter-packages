import 'package:app_template/features/settings/domain/entities/app_locale.dart';

abstract interface class SetLocaleUseCase {
  Future<void> call(AppLocale locale);
}

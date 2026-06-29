import 'package:app_template/features/settings/domain/entities/app_locale.dart';

abstract interface class GetEffectiveLocaleUseCase {
  /// Get the effective locale of the app.
  Future<AppLocale> call();
}

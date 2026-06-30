import 'package:app_template/features/settings/domain/entities/app_locale.dart';
import 'package:app_template/features/settings/domain/entities/locale_components.dart';
import 'package:app_template/features/settings/domain/services/app_locale_resolver.dart';

abstract interface class GetPlatformLocaleUseCase {
  /// Returns the platform locale.
  ///
  /// This may not correspond to any of the supported locales defined in
  /// [AppLocale]. In case you need a match from a [LocaleComponents] to
  /// an [AppLocale], use [AppLocaleResolver] instead.
  Future<LocaleComponents> call();
}

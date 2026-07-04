import 'package:app_template/features/app/domain/models/app_locale.dart';
import 'package:app_template/features/app/domain/models/locale_components.dart';
import 'package:app_template/features/app/domain/services/app_locale_resolver.dart';

/// Returns the platform locale.
///
/// This may not correspond to any of the supported locales defined in
/// [AppLocale]. In case you need a match from a [LocaleComponents] to
/// an [AppLocale], use [AppLocaleResolver] instead.
abstract interface class GetPlatformLocaleUseCase {
  Future<LocaleComponents> call();
}

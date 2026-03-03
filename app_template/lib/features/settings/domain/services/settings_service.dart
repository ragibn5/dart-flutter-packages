import 'package:app_template/features/settings/domain/models/app_locale.dart';
import 'package:app_template/features/settings/domain/models/app_theme_mode.dart';

abstract interface class SettingsService {
  /// Returns the **effective app locale**
  ///
  /// Resolution order:
  /// 1. If the user explicitly selected a locale earlier, it is returned.
  /// 2. Otherwise, if the platform's locale can be mapped to one of the
  ///    supported locales (i.e. [AppLocale.values]) it is returned.
  ///    If none of the above works out,  [AppLocale.EN] is returned.
  ///
  /// This method does not persist any value.
  Future<AppLocale> getEffectiveLocale();

  /// Returns the **effective app theme mode**.
  ///
  /// Resolution order:
  /// 1. If the user explicitly selected a theme-mode earlier, it is returned.
  /// 2. Otherwise, [AppThemeMode.SYSTEM] is returned.
  ///
  /// This method does not persist any value.
  Future<AppThemeMode> getEffectiveThemeMode();

  /// Persists the user-selected app locale.
  ///
  /// This call will also add the [locale] to any stream obtained from
  /// [watchLocale].
  Future<void> setLocale(AppLocale locale);

  /// Persists the user-selected app theme mode.
  ///
  /// This call will also add the [themeMode] to any stream obtained from
  /// [watchThemeMode].
  Future<void> setThemeMode(AppThemeMode themeMode);

  /// Watch locale selection changes.
  ///
  /// This emits a new value whenever the user changes the app-locale,
  /// specifically, by calling the [setLocale] method.
  ///
  /// **Please note**: Do not call [setLocale] in response to events
  /// received from the stream return by this method, as it will result
  /// in an infinite loop.
  Stream<AppLocale> watchLocale();

  /// Watch theme-mode selection changes.
  ///
  /// This emits a new value whenever the user changes the app-theme-mode,
  /// for example, by calling the [setThemeMode] method.
  ///
  /// **Please note**: Do not call [setThemeMode] in response to events
  /// received from the stream return by this method, as it will result
  /// in an infinite loop.
  Stream<AppThemeMode> watchThemeMode();
}

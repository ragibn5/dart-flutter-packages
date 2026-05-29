import 'dart:async';

import 'package:app_template/features/settings/domain/models/app_locale.dart';
import 'package:app_template/features/settings/domain/models/app_theme_mode.dart';
import 'package:app_template/features/settings/domain/repositories/settings_repository.dart';
import 'package:app_template/features/settings/domain/services/app_locale_resolver.dart';
import 'package:app_template/features/settings/domain/services/platform_settings_provider.dart';
import 'package:app_template/features/settings/domain/services/settings_service.dart';

class SettingsServiceImpl implements SettingsService {
  final AppLocaleResolver _appLocaleResolver;
  final PlatformSettingsProvider _platformSettingsProvider;
  final SettingsRepository _settingsRepository;

  SettingsServiceImpl(
    AppLocaleResolver appLocaleResolver,
    PlatformSettingsProvider platformSettingsProvider,
    SettingsRepository settingsRepository,
  ) : _appLocaleResolver = appLocaleResolver,
      _platformSettingsProvider = platformSettingsProvider,
      _settingsRepository = settingsRepository;

  @override
  Future<AppLocale> getEffectiveLocale() async {
    final persistedSettings = await _settingsRepository.getCurrentSettings();
    if (persistedSettings.locale != null) {
      return persistedSettings.locale!;
    }

    return _resolvePlatformLocale(AppLocale.EN);
  }

  @override
  Future<void> setLocale(AppLocale locale) async {
    final persistedSettings = await _settingsRepository.getCurrentSettings();
    await _settingsRepository.setCurrentSettings(
      persistedSettings.copyWith(locale: locale),
    );
  }

  @override
  Stream<AppLocale> watchLocale() => _settingsRepository
      .getSettingsStream()
      .map((e) => e.locale ?? _resolvePlatformLocale(AppLocale.EN))
      .distinct();

  @override
  Future<AppThemeMode> getEffectiveThemeMode() async {
    final persistedSettings = await _settingsRepository.getCurrentSettings();
    if (persistedSettings.themeMode != null) {
      return persistedSettings.themeMode!;
    }

    return AppThemeMode.SYSTEM;
  }

  @override
  Future<void> setThemeMode(AppThemeMode themeMode) async {
    final persistedSettings = await _settingsRepository.getCurrentSettings();
    await _settingsRepository.setCurrentSettings(
      persistedSettings.copyWith(themeMode: themeMode),
    );
  }

  @override
  Stream<AppThemeMode> watchThemeMode() => _settingsRepository
      .getSettingsStream()
      .map((settings) => settings.themeMode ?? AppThemeMode.SYSTEM)
      .distinct();

  AppLocale _resolvePlatformLocale(AppLocale defaultValue) {
    final platformLocale = _platformSettingsProvider.getSystemaLocale();
    return _appLocaleResolver.resolveLocale(platformLocale) ?? AppLocale.EN;
  }
}

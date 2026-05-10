import 'package:app_template/features/app/infrastructure/models/app_config.dart';
import 'package:app_template/features/app/infrastructure/services/fallback_locale_selector.dart';
import 'package:app_template/generated/l10n.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:injectable/injectable.dart';
import 'package:package_info_plus/package_info_plus.dart';

@singleton
class AppConfigFactory {
  final PackageInfo _packageInfo;
  final FallbackLocaleSelector _fallbackLocaleSelector;

  AppConfigFactory(this._packageInfo, this._fallbackLocaleSelector);

  AppConfig create(PlatformDispatcher platformDispatcher) {
    return AppConfig(
      restorationScopeId: _packageInfo.packageName,
      designSize: const Size(360, 640),
      lightThemeData: ThemeData.light(),
      darkThemeData: ThemeData.dark(),
      supportedLocales: S.delegate.supportedLocales,
      defaultThemeMode: ThemeMode.system,
      defaultLocale: _fallbackLocaleSelector.determineDefaultLocale(
        S.delegate.supportedLocales.first,
        S.delegate.supportedLocales,
        platformDispatcher,
      ),
      localizationDelegates: [
        S.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}

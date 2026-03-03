import 'package:flutter/material.dart';

class AppConfig {
  /// The restoration scope id used to save and restore the app's state.
  final String restorationScopeId;

  /// The design size of the app.
  /// This is used to calculate the font size.
  final Size designSize;

  /// The default theme mode.
  /// It may be used before we load it from the settings/persistent-storage.
  final ThemeMode defaultThemeMode;

  /// The light theme specification.
  final ThemeData lightThemeData;

  /// The dark theme specification.
  final ThemeData darkThemeData;

  /// The default locale.
  /// It may be used before we load it from the settings/persistent-storage.
  /// Must be one of the supported locales specified by [supportedLocales].
  final Locale defaultLocale;

  /// The list of supported locales.
  final List<Locale> supportedLocales;

  /// The list of localization delegates that should be used by the app.
  final List<LocalizationsDelegate<dynamic>> localizationDelegates;

  AppConfig({
    required this.restorationScopeId,
    required this.defaultThemeMode,
    required this.lightThemeData,
    required this.darkThemeData,
    required this.defaultLocale,
    required this.supportedLocales,
    required this.localizationDelegates,
    required this.designSize,
  });

  AppConfig copyWith({
    String? restorationScopeId,
    Size? designSize,
    ThemeMode? defaultThemeMode,
    ThemeData? lightThemeData,
    ThemeData? darkThemeData,
    Locale? defaultLocale,
    List<Locale>? supportedLocales,
    List<LocalizationsDelegate<dynamic>>? localizationDelegates,
  }) {
    return AppConfig(
      restorationScopeId: restorationScopeId ?? this.restorationScopeId,
      designSize: designSize ?? this.designSize,
      defaultThemeMode: defaultThemeMode ?? this.defaultThemeMode,
      lightThemeData: lightThemeData ?? this.lightThemeData,
      darkThemeData: darkThemeData ?? this.darkThemeData,
      defaultLocale: defaultLocale ?? this.defaultLocale,
      supportedLocales: supportedLocales ?? this.supportedLocales,
      localizationDelegates:
          localizationDelegates ?? this.localizationDelegates,
    );
  }
}

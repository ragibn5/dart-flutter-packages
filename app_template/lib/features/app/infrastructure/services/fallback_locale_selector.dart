import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';

@singleton
class FallbackLocaleSelector {
  const FallbackLocaleSelector();

  Locale determineDefaultLocale(
    Locale fallbackLocale,
    List<Locale> supportedLocales,
    PlatformDispatcher platformDispatcher,
  ) {
    final platformLocale = platformDispatcher.locale;
    final matchFromPlatform = supportedLocales
        .where((l) => l.languageCode == platformLocale.languageCode)
        .firstOrNull;

    return matchFromPlatform ?? fallbackLocale;
  }
}

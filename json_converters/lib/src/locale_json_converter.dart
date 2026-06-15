import 'dart:ui';

import 'package:json_annotation/json_annotation.dart';

class LocaleJsonConverter implements JsonConverter<Locale, String> {
  const LocaleJsonConverter();

  @override
  Locale fromJson(String languageTag) {
    final parts = languageTag.split('-');
    if (parts.isEmpty) {
      throw FormatException('Invalid BCP-47 tag: $languageTag');
    }

    final language = parts[0];
    if (!(language.length == 2 || language.length == 3)) {
      throw FormatException('Invalid language code: $language');
    }

    String? script;
    String? country;
    for (var i = 1; i < parts.length; i++) {
      final part = parts[i];
      if (part.length == 4 && script == null) {
        script = part;
      } else if (part.length == 2 && country == null) {
        country = part;
      } else {
        throw FormatException('Invalid segment: $part');
      }
    }

    return Locale.fromSubtags(
      languageCode: language,
      scriptCode: script,
      countryCode: country,
    );
  }

  @override
  String toJson(Locale locale) {
    return locale.toLanguageTag();
  }
}

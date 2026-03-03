import 'dart:ui';

import 'package:json_annotation/json_annotation.dart';

/// A [JsonConverter] to convert a [Locale] instance to a BCP-47 standard
/// tag and vice versa.
class LocaleJsonConverter implements JsonConverter<Locale, String> {
  const LocaleJsonConverter();

  @override
  Locale fromJson(String languageTag) {
    final parts = languageTag.split('-');
    if (parts.isEmpty) {
      throw FormatException('Invalid BCP-47 tag: $languageTag');
    }

    // Extract language (mandatory).
    final language = parts[0];
    if (!(language.length == 2 || language.length == 3)) {
      throw FormatException('Invalid language code: $language');
    }

    // Extract script/country (optional).
    String? script;
    String? country;
    for (var i = 1; i < parts.length; i++) {
      final part = parts[i];
      if (part.length == 4 && script == null) {
        // Script must be 4 letters.
        script = part;
      } else if (part.length == 2 && country == null) {
        // Country must be 2 letters.
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

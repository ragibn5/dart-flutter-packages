import 'package:json_converters/json_converters.dart';

void main() {
  const dateConverter = Rfc3339UTCDateTimeJsonConverter();
  final now = DateTime.now().toUtc();
  final json = dateConverter.toJson(now);
  final parsed = dateConverter.fromJson(json);
  print('$now -> $json -> $parsed');

  const localeConverter = LocaleJsonConverter();
  final locale = localeConverter.fromJson('en-US');
  final tag = localeConverter.toJson(locale);
  print('en-US -> $locale -> $tag');
}

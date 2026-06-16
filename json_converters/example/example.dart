import 'package:json_converters/json_converters.dart';

void main() {
  final dateConverter = Rfc3339UTCDateTimeJsonConverter();
  final now = DateTime.now().toUtc();
  final json = dateConverter.toJson(now);
  final parsed = dateConverter.fromJson(json);
  print('$now -> $json -> $parsed');

  final localeConverter = LocaleJsonConverter();
  final locale = localeConverter.fromJson('en-US');
  final tag = localeConverter.toJson(locale);
  print('en-US -> $locale -> $tag');
}

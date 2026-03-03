import 'package:datetime_utils/datetime_utils.dart';
import 'package:json_annotation/json_annotation.dart';

/// A [JsonConverter] to convert a [DateTime] instance to a RFC-3339 standard
/// format and vice versa.
class Rfc3339UTCDateTimeJsonConverter
    implements JsonConverter<DateTime, String> {
  const Rfc3339UTCDateTimeJsonConverter();

  @override
  DateTime fromJson(String json) {
    return _rfcConverter.fromRFC3339StringToUtc(json);
  }

  @override
  String toJson(DateTime dateTime) {
    return dateTime.toRFC3339UtcString();
  }

  RFCDateTimeConverters get _rfcConverter => const RFCDateTimeConverters();
}

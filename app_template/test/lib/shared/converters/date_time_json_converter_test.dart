// ignore_for_file: lines_longer_than_80_chars

import 'package:app_template/shared/converters/date_time_json_converter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const converter = Rfc3339UTCDateTimeJsonConverter();

  setUp(() {});

  test('`fromJson` should convert RFC-3339 string to DateTime', () {
    // Use a non-zero time to fully verify parsing
    final dateTime = converter.fromJson('2023-05-12T13:27:45.123456Z');
    expect(
      dateTime,
      isA<DateTime>()
          .having((dt) => dt.year, 'Year', 2023)
          .having((dt) => dt.month, 'Month', 5)
          .having((dt) => dt.day, 'Day', 12)
          .having((dt) => dt.hour, 'Hour', 13)
          .having((dt) => dt.minute, 'Minute', 27)
          .having((dt) => dt.second, 'Second', 45)
          .having((dt) => dt.millisecond, 'Millisecond', 123)
          .having((dt) => dt.microsecond, 'Microsecond', 456)
          .having((dt) => dt.timeZoneOffset.inHours, 'TimeZoneOffset', 0)
          .having((dt) => dt.isUtc, 'IsUtc', true),
    );
  });

  test('`toJson` should convert DateTime to RFC-3339 string', () {
    // Non-zero DateTime to fully verify serialization
    final dateTime = DateTime.utc(
      2024,
      // year
      6,
      // month
      18,
      // day
      9,
      // hour
      42,
      // minute
      37,
      // second
      789,
      // millisecond
      123, // microsecond
    );

    final json = converter.toJson(dateTime);
    final parsed = converter.fromJson(json);

    expect(
      parsed,
      isA<DateTime>()
          .having((dt) => dt.year, 'Year', 2024)
          .having((dt) => dt.month, 'Month', 6)
          .having((dt) => dt.day, 'Day', 18)
          .having((dt) => dt.hour, 'Hour', 9)
          .having((dt) => dt.minute, 'Minute', 42)
          .having((dt) => dt.second, 'Second', 37)
          .having((dt) => dt.millisecond, 'Millisecond', 789)
          .having((dt) => dt.microsecond, 'Microsecond', 123)
          .having((dt) => dt.timeZoneOffset.inHours, 'TimeZoneOffset', 0)
          .having((dt) => dt.isUtc, 'IsUtc', true),
    );
  });
}

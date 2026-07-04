import 'package:enum_parser/enum_parser.dart';
import 'package:test/test.dart';

enum _Color { red, green, blue }

enum _StatusCode { ok, notFound, internalError }

void main() {
  test('Parses exact case match', () {
    final result = parseEnum(
      _Color.values,
      rawValue: 'green',
      fallbackValue: _Color.red,
    );
    expect(result, _Color.green);
  });

  test('Parses case-insensitively by default', () {
    final result = parseEnum(
      _Color.values,
      rawValue: 'GREEN',
      fallbackValue: _Color.red,
    );
    expect(result, _Color.green);
  });

  test('Returns fallback for null rawValue', () {
    final result = parseEnum(
      _Color.values,
      rawValue: null,
      fallbackValue: _Color.blue,
    );
    expect(result, _Color.blue);
  });

  test('Returns fallback for non-matching rawValue', () {
    final result = parseEnum(
      _Color.values,
      rawValue: 'purple',
      fallbackValue: _Color.red,
    );
    expect(result, _Color.red);
  });

  test('Returns fallback for empty string', () {
    final result = parseEnum(
      _Color.values,
      rawValue: '',
      fallbackValue: _Color.green,
    );
    expect(result, _Color.green);
  });

  test('Works with different enum types', () {
    final result = parseEnum(
      _StatusCode.values,
      rawValue: 'NOTFOUND',
      fallbackValue: _StatusCode.ok,
    );
    expect(result, _StatusCode.notFound);
  });

  test('Respects ignoreCase: false', () {
    final result = parseEnum(
      _Color.values,
      rawValue: 'RED',
      fallbackValue: _Color.blue,
      ignoreCase: false,
    );
    expect(result, _Color.blue);
  });

  test('Respects ignoreCase: false with exact match', () {
    final result = parseEnum(
      _Color.values,
      rawValue: 'red',
      fallbackValue: _Color.blue,
      ignoreCase: false,
    );
    expect(result, _Color.red);
  });
}

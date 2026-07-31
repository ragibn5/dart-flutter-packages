import 'package:json_parser/json_parser.dart';
import 'package:test/test.dart';

void main() {
  test('is an Exception', () {
    expect(JsonParseException('boom'), isA<Exception>());
  });

  test('exposes the message', () {
    expect(JsonParseException('Expected int').message, 'Expected int');
  });

  test('toString() omits the path when empty', () {
    expect(JsonParseException('boom').toString(), 'boom');
  });

  test('toString() quotes string segments and renders indices bare', () {
    final e = JsonParseException('Expected int', ['users', 3, 'age']);
    expect(e.toString(), r"Expected int at $['users'][3]['age']");
  });
}

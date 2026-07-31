import 'package:json_parser/json_parser.dart';
import 'package:test/test.dart';

void main() {
  test('list parser reports the failing index', () {
    const parser = ListParser(IntParser());

    expect(
      () => parser.decode([1, 'x']),
      throwsA(
        isA<JsonParseException>().having((e) => e.path, 'path', [1]),
      ),
    );
  });

  test('nested parsers report the full path', () {
    const parser = MapParser(
      keyParser: StringParser(),
      valueParser: ListParser(
        MapParser(
          keyParser: StringParser(),
          valueParser: IntParser(),
        ),
      ),
    );

    final encoded = {
      'users': [
        {'age': 30},
        {'age': 'x'},
      ],
    };

    expect(
      () => parser.decode(encoded),
      throwsA(
        isA<JsonParseException>()
            .having((e) => e.path, 'path', ['users', 1, 'age']).having(
          (e) => e.toString(),
          'toString',
          r"Expected number, but got String at $['users'][1]['age']",
        ),
      ),
    );
  });
}

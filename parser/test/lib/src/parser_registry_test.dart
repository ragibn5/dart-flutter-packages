// ignore_for_file: cascade_invocations

import 'package:meta/meta.dart';
import 'package:parser/parser.dart';
import 'package:test/test.dart';

@immutable
class _User {
  final int id;
  final String name;

  const _User(this.id, this.name);

  @override
  String toString() {
    return 'User{id: $id, name: $name}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _User && id == other.id && name == other.name;

  @override
  int get hashCode => id.hashCode ^ name.hashCode;
}

// Minimal User parser for testing
class _UserParser implements Parser<_User, Map<String, dynamic>> {
  const _UserParser();

  @override
  Map<String, dynamic> encode(_User value) =>
      {'id': value.id, 'name': value.name};

  @override
  _User decode(Map<String, dynamic> encoded) =>
      _User(encoded['id'] as int, encoded['name'] as String);
}

// Test registry
class _TestParserRegistry extends ParserRegistry<Map<String, dynamic>> {
  _TestParserRegistry() : super.test({});
}

void main() {
  late _TestParserRegistry sut;

  setUp(() {
    sut = _TestParserRegistry();
  });

  test('Initially empty', () {
    expect(sut.parserMap, isEmpty);
  });

  test('Can add and retrieve parser by generic type parameter', () {
    const parser = _UserParser();

    sut.addParser<_User>(parser);

    final retrieved = sut.getParser<_User>();
    expect(retrieved, isA<_UserParser>().having((p) => p, 'parser', parser));
  });

  test('getParser returns null if type not registered', () {
    expect(sut.getParser<int>(), isNull);
  });

  test('getRuntimeParser returns parser by runtime type', () {
    const parser = _UserParser();

    sut.addParser<_User>(parser);

    final runtimeParser = sut.getRuntimeParser(_User);
    expect(
      runtimeParser,
      isA<_UserParser>().having((p) => p, 'parser', parser),
    );
  });

  test('getRuntimeParser returns null if type not registered', () {
    expect(sut.getRuntimeParser(String), isNull);
  });
}

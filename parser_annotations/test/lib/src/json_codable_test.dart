import 'package:parser_annotations/parser_annotations.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

void main() {
  test('JsonCodable() is constructed with correct valid default params', () {
    const sut = JsonCodable();

    expect(sut.autoRegister, true);
    expect(sut.parserKeys, const <String>{});
    expect(sut.requireToJson, true);
    expect(sut.requireFromJson, true);
  });
}

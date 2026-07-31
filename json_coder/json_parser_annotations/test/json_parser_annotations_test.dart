import 'package:json_parser_annotations/json_parser_annotations.dart';
import 'package:test/test.dart';

void main() {
  test('Uses the default registry key when none is provided', () {
    const annotation = GenerateJsonParser();

    expect(annotation.registryKeys, {'default'});
  });

  test('Keeps explicitly provided empty set', () {
    const annotation = GenerateJsonParser(
      registryKeys: <String>{},
    );

    expect(annotation.registryKeys, isEmpty);
  });

  test('Keeps explicitly provided registry keys', () {
    const annotation = GenerateJsonParser(
      registryKeys: {'dev', 'prod'},
    );

    expect(annotation.registryKeys, {'dev', 'prod'});
  });
}

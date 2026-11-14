import 'package:generator_core/generator_core.dart';
import 'package:json_parser_generator/builder.dart';
import 'package:test/test.dart';

void main() {
  test('jsonParsersBuilderShouldBuildTheJsonParsersBuilderIfCalled', () {
    expect(jsonParsersBuilder(BuilderOptions.empty), isA<Builder>());
  });
}

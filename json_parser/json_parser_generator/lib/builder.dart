import 'package:generator_core/generator_core.dart';
import 'package:json_parser_generator/src/builders/json_parsers_builder.dart';

Builder jsonParsersBuilder(BuilderOptions options) => JsonParsersBuilder(
  options,
  const JsonParsersBuilderConfig(
    outputPathRelativeToLib: 'generated/json_parser/parsers.dart',
  ),
);

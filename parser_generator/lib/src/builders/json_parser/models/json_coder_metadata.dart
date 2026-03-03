import 'package:generator_core/generator_core.dart';

class JsonCoderMetadata extends ClassMetadata {
  final Set<String> parserKeys;

  JsonCoderMetadata(super.uri, super.name, this.parserKeys);
}

import 'package:generator_core/generator_core.dart';

class JsonParserGeneratorContextConfig extends ContextConfig {
  JsonParserGeneratorContextConfig({required super.logConfig});

  @override
  Map<String, dynamic> toMap() => {'logConfig': logConfig.toMap()};
}

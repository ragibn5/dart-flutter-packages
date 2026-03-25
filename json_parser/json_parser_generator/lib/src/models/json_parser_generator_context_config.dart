import 'package:generator_core/generator_core.dart';

class JsonParserGeneratorContextConfig extends ContextConfig {
  JsonParserGeneratorContextConfig({
    required super.packageInfo,
    required super.logConfig,
  });

  @override
  Map<String, dynamic> toMap() => {
    'packageInfo': packageInfo.toMap(),
    'logConfig': logConfig.toMap(),
  };
}

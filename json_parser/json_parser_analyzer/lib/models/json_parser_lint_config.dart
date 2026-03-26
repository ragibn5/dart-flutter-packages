import 'package:analysis_server_core/analysis_server_core.dart';

class JsonParserLintConfig extends ContextConfig {
  JsonParserLintConfig({
    required super.packageInfo,
    required super.logConfig,
    super.scanConfig,
  });

  @override
  Map<String, dynamic> toMap() => {
    'packageInfo': packageInfo.toMap(),
    'logConfig': logConfig.toMap(),
    'scanConfig': scanConfig.toMap(),
  };
}

import 'package:analysis_server_plugin_core/analysis_server_plugin_core.dart';

class JsonParserAnalyzerConfig extends ContextConfig {
  JsonParserAnalyzerConfig({
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

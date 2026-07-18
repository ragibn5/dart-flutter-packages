import 'package:analysis_server_plugin_core/analysis_server_plugin_core.dart';
import 'package:clean_arch_lint/src/models/ddr_config.dart';

class CleanArchLintConfig extends ContextConfig {
  final DependencyDirectionRuleConfig ddrConfig;

  CleanArchLintConfig({
    required super.packageInfo,
    required super.logConfig,
    super.scanConfig,
    this.ddrConfig = const DependencyDirectionRuleConfig(),
  });

  @override
  Map<String, dynamic> toMap() => {
    'packageInfo': packageInfo.toMap(),
    'logConfig': logConfig.toMap(),
    'scanConfig': scanConfig.toMap(),
    'ddrConfig': ddrConfig.toMap(),
  };
}

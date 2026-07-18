import 'package:analysis_server_plugin_core/analysis_server_plugin_core.dart';
import 'package:clean_arch_lint/src/models/ddr_config.dart';

class DefaultConfigOptions {
  final LogConfig logConfig;
  final ScanConfig scanConfig;
  final DependencyDirectionRuleConfig ddrConfig;

  const DefaultConfigOptions({
    required this.logConfig,
    required this.scanConfig,
    required this.ddrConfig,
  });
}

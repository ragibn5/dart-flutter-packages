import 'package:analysis_server_core/analysis_server_core.dart';

class DefaultConfigOptions {
  final LogConfig logConfig;
  final ScanConfig scanConfig;

  const DefaultConfigOptions({
    required this.logConfig,
    required this.scanConfig,
  });
}

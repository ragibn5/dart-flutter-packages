import 'package:analysis_server_plugin_core/analysis_server_plugin_core.dart';
import 'package:clean_arch_linter/src/models/cross_layer_import_config.dart';
import 'package:clean_arch_linter/src/models/dart_sdk_import_config.dart';
import 'package:clean_arch_linter/src/models/domain_config.dart';
import 'package:clean_arch_linter/src/models/third_party_import_config.dart';

class DefaultConfigOptions {
  final LogConfig logConfig;
  final ScanConfig scanConfig;
  final DomainConfig domainConfig;
  final DartSDKImportConfig dartSDKConfig;
  final CrossLayerImportConfig crossLayerConfig;
  final ThirdPartyImportConfig thirdPartyConfig;

  const DefaultConfigOptions({
    required this.logConfig,
    required this.scanConfig,
    required this.domainConfig,
    required this.dartSDKConfig,
    required this.crossLayerConfig,
    required this.thirdPartyConfig,
  });
}

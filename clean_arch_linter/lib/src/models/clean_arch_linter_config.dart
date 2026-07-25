import 'package:analysis_server_plugin_core/analysis_server_plugin_core.dart';
import 'package:clean_arch_linter/src/models/cross_layer_import_config.dart';
import 'package:clean_arch_linter/src/models/dart_sdk_import_config.dart';
import 'package:clean_arch_linter/src/models/domain_config.dart';
import 'package:clean_arch_linter/src/models/third_party_import_config.dart';

class CleanArchLinterConfig extends ContextConfig {
  final DomainConfig domainConfig;
  final DartSDKImportConfig dartSDKConfig;
  final CrossLayerImportConfig crossLayerConfig;
  final ThirdPartyImportConfig thirdPartyConfig;

  CleanArchLinterConfig({
    required super.packageInfo,
    required super.logConfig,
    super.scanConfig,
    this.domainConfig = const DomainConfig(),
    this.dartSDKConfig = const DartSDKImportConfig(),
    this.crossLayerConfig = const CrossLayerImportConfig(),
    this.thirdPartyConfig = const ThirdPartyImportConfig(),
  });

  @override
  Map<String, dynamic> toMap() => {
    'packageInfo': packageInfo.toMap(),
    'logConfig': logConfig.toMap(),
    'scanConfig': scanConfig.toMap(),
    'domainConfig': domainConfig.toMap(),
    'dartSDKConfig': dartSDKConfig.toMap(),
    'crossLayerConfig': crossLayerConfig.toMap(),
    'thirdPartyConfig': thirdPartyConfig.toMap(),
  };
}

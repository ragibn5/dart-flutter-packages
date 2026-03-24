import 'package:generator_core/generator_core.dart';

class BuildContextConfig extends ContextConfig {
  BuildContextConfig({required super.packageInfo, required super.logConfig});

  @override
  Map<String, dynamic> toMap() => {
    'packageInfo': packageInfo.toMap(),
    'logConfig': logConfig.toMap(),
  };
}

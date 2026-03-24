import 'package:build/build.dart';
import 'package:generator_core/src/models/context_config.dart';
import 'package:generator_core/src/models/package_info.dart';
import 'package:meta/meta.dart';

abstract class ContextConfigLoader<C extends ContextConfig> {
  /// Load plugin specific config.
  ///
  /// You may use the passed [PackageInfo] instance directly
  /// to construct return value ([ContextConfig] requires a [PackageInfo]).
  C loadPluginConfig(BuildStep buildStep, PackageInfo packageInfo);

  /// Load the config for the given [BuildStep] instance.
  @mustCallSuper
  Future<ContextConfig> loadConfig(BuildStep buildStep) async {
    final packageInfo = await _extractPackageInfo(buildStep);
    return loadPluginConfig(buildStep, packageInfo);
  }

  /// Extracts [PackageInfo] from the given [buildStep].
  ///
  /// Throws `StateError` if `buildStep.inputId.package` doesn't
  /// match any packages from `buildStep.packageConfig.packages`.
  /// This should never happen unless there is a bug in the `build`
  /// package.
  Future<PackageInfo> _extractPackageInfo(BuildStep buildStep) async {
    final package = (await buildStep.packageConfig).packages
        .where((e) => e.name == buildStep.inputId.package)
        .firstOrNull;

    if (package == null) {
      // This should never happen
      throw StateError(
        'Invalid package configuration - '
        "package from asset doesn't match any packages from package configs.",
      );
    }

    return PackageInfo(name: package.name, location: package.root.path);
  }
}

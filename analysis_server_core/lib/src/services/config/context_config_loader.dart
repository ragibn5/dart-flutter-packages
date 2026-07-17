// ignore_for_file: avoid_dynamic_calls

import 'package:analysis_server_core/src/models/context_config.dart';
import 'package:analysis_server_core/src/models/package_info.dart';
import 'package:analysis_server_core/src/services/config/config_source_provider.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:functionals/functionals.dart';
import 'package:meta/meta.dart';
import 'package:yaml/yaml.dart';

abstract class ContextConfigLoader<C extends ContextConfig> {
  final ConfigSourceProvider _configSourceProvider;

  ContextConfigLoader() : this._(ConfigSourceProviderImpl());

  @visibleForTesting
  ContextConfigLoader.test(ConfigSourceProvider configSourceProvider)
    : this._(configSourceProvider);

  ContextConfigLoader._(this._configSourceProvider);

  /// Load plugin specific config.
  ///
  /// You may use the passed [PackageInfo] instance directly
  /// to construct return value ([ContextConfig] requires a [PackageInfo]).
  C loadPluginConfig(RuleContext context, PackageInfo packageInfo);

  /// Load the config for the given [RuleContext] instance.
  @mustCallSuper
  ContextConfig loadConfig(RuleContext context) {
    final packageInfo = _extractPackageInfo(context);
    return loadPluginConfig(context, packageInfo);
  }

  /// Extracts [PackageInfo] from the given [RuleContext].
  ///
  /// This method attempts to identify the Dart package containing the
  /// compilation unit being analyzed.
  ///
  /// If the unit is not part of a package (e.g., a standalone script),
  /// or if the `pubspec.yaml` is missing or invalid, it returns a [PackageInfo]
  /// with a `null` name and uses the directory containing the compilation unit
  /// as the location.
  PackageInfo _extractPackageInfo(RuleContext context) {
    final package = context.package;
    final unitParentLocation = context.definingUnit.file.parent.path;
    if (package == null) {
      // Not from a dart package.
      // - Package name is null.
      // - Package location unit's parent dir.
      return PackageInfo(name: null, location: unitParentLocation);
    }

    final packageRootPath = package.root.path;
    final pubspecFile = _configSourceProvider.getConfigSource(
      package,
      'pubspec.yaml',
    );
    if (!pubspecFile.existsSync()) {
      // If there is no pubspec file and the analysis server still identified
      // it as a dart package (not likely going to happen), considering it as
      // non-package compilation unit. So,
      // - Package name is null.
      // - Package location (Compilation unit location tbh) is the parent dir.
      return PackageInfo(name: null, location: unitParentLocation);
    }

    final pubspecContent = pubspecFile.readAsStringSync();
    final parsedPubspec = runCatching(
      () => loadYaml(pubspecContent) as YamlMap?,
      defaultValue: null,
    );
    if (parsedPubspec == null) {
      // If twe were unable to load/parse the pubspec.yaml file
      // (not likely going to happen), considering it as non-package
      // compilation unit. So,
      // - Package name is null.
      // - Package location (Compilation unit location tbh) is the parent dir.
      return PackageInfo(name: null, location: unitParentLocation);
    }

    final packageName = runCatching(
      () => parsedPubspec['name'] as String,
      defaultValue: null,
    );
    if (packageName == null) {
      // If twe were unable to find the name field within the pubspec.yaml
      // file (not likely going to happen), considering it as non-package
      // compilation unit. So,
      // - Package name is null.
      // - Package location (Compilation unit location tbh) is the parent dir.
      return PackageInfo(name: null, location: unitParentLocation);
    }

    // At this point, we are sure that the compilation unit belongs
    // to a valid dart package. So,
    // - We have a valid package name.
    // - Package location is the root of the package.
    return PackageInfo(name: packageName, location: packageRootPath);
  }
}

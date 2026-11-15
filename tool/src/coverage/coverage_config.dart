import 'dart:io';

import 'package:yaml/yaml.dart';

const _defaultThreshold = 100.0;

/// The settings in the coverage.yaml at [path]; none when it's missing or
/// holds no map.
CoverageConfig readConfig(String path) {
  final doc = _readYamlMap(path);
  if (doc == null) return const CoverageConfig.empty();
  return CoverageConfig(
    exclude: _readExclude(doc),
    threshold: _readThreshold(doc),
  );
}

/// The package's threshold, else the --threshold argument, else the default.
double requiredThreshold(CoverageConfig packageConfig, List<String> args) =>
    packageConfig.threshold ?? _thresholdArg(args) ?? _defaultThreshold;

/// The repository's exclusions, then the package's.
List<String> combinedExclude(
  CoverageConfig repoConfig,
  CoverageConfig packageConfig,
) => [...repoConfig.exclude, ...packageConfig.exclude];

/// The YAML map in the file at [path]; `null` when it's missing or holds no
/// map.
YamlMap? _readYamlMap(String path) {
  final file = File(path);
  if (!file.existsSync()) return null;
  final doc = loadYaml(file.readAsStringSync());
  return doc is YamlMap ? doc : null;
}

List<String> _readExclude(YamlMap config) {
  final exclude = config['exclude'];
  return exclude is YamlList ? exclude.map((e) => '$e').toList() : const [];
}

double? _readThreshold(YamlMap config) {
  final threshold = config['threshold'];
  return threshold is num ? threshold.toDouble() : null;
}

double? _thresholdArg(List<String> args) {
  final i = args.indexOf('--threshold');
  return i >= 0 && i + 1 < args.length ? double.tryParse(args[i + 1]) : null;
}

/// A coverage.yaml's settings.
class CoverageConfig {
  /// The required line coverage in percent, or `null` for the default.
  final double? threshold;

  /// lcov globs of the files to leave out.
  final List<String> exclude;

  const CoverageConfig({required this.exclude, required this.threshold});

  /// No settings: what a missing or empty coverage.yaml gives.
  const CoverageConfig.empty() : exclude = const [], threshold = null;
}

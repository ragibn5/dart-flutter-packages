import 'dart:io';

import 'package:yaml/yaml.dart';

/// A package's own coverage settings, read from its
/// `dev_tools_coverage_config.yaml`.
typedef CoverageConfig = ({List<String> exclude, double? threshold});

const _emptyConfig = (exclude: <String>[], threshold: null);

/// Reads a package's own coverage config, so each package can exclude
/// generated/boilerplate files from its coverage and/or override the
/// required threshold — without a shared, repo-wide default for either,
/// since both genuinely differ per package.
class ReadCoverageConfig {
  const ReadCoverageConfig();

  /// Params:
  /// - `packagePath`: absolute path to the package.
  ///
  /// Returns: the package's
  /// `<packagePath>/dev_tools_coverage_config.yaml`, parsed as:
  /// ```yaml
  /// threshold: 90 # optional, overrides the batch-wide default
  /// exclude: # optional, lcov glob patterns
  ///   - lib/generated/**
  ///   - lib/**/*.g.dart
  /// ```
  /// Both fields are optional; either or both may be omitted. Returns an
  /// empty config (no exclusions, no threshold override) when the file
  /// doesn't exist.
  Future<CoverageConfig> call(String packagePath) async {
    final file = File('$packagePath/dev_tools_coverage_config.yaml');
    if (!file.existsSync()) return _emptyConfig;

    final doc = loadYaml(await file.readAsString());
    if (doc is! YamlMap) return _emptyConfig;

    final rawExclude = doc['exclude'];
    final exclude = rawExclude is YamlList
        ? rawExclude.map((e) => e.toString()).toList()
        : <String>[];

    final rawThreshold = doc['threshold'];
    final threshold = rawThreshold is num ? rawThreshold.toDouble() : null;

    return (exclude: exclude, threshold: threshold);
  }
}

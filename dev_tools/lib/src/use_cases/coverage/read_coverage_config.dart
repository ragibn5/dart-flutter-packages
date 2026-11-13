import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

/// A package's coverage settings: its own `dev_tools_coverage_config.yaml`,
/// on top of the repository's.
typedef CoverageConfig = ({List<String> exclude, double? threshold});

const _configFileName = 'dev_tools_coverage_config.yaml';

const _emptyConfig = (exclude: <String>[], threshold: null);

/// Reads a package's coverage config, so generated and boilerplate files can
/// be left out of its coverage, repo-wide or per package, and a package can
/// override the required threshold.
class ReadCoverageConfig {
  const ReadCoverageConfig();

  /// Params:
  /// - `packagePath`: absolute path to the package.
  ///
  /// Returns: the package's `<packagePath>/dev_tools_coverage_config.yaml`,
  /// parsed as:
  /// ```yaml
  /// threshold: 90 # optional, overrides the batch-wide default
  /// exclude: # optional, lcov glob patterns
  ///   - lib/generated/**
  ///   - lib/**/*.g.dart
  /// ```
  /// with the `exclude` patterns of the repository root's
  /// `dev_tools_coverage_config.yaml` added in front of the package's own.
  /// The repository root is the nearest folder above the package that holds
  /// a `.git` entry; its `threshold` is ignored, since the batch-wide default
  /// already applies to every package.
  ///
  /// Every field is optional, and so is either file: without both, the
  /// config is empty (no exclusions, no threshold override).
  Future<CoverageConfig> call(String packagePath) async {
    final packageConfig = await _read(p.join(packagePath, _configFileName));
    final repoRoot = _findRepoRoot(packagePath);
    final repoConfig = repoRoot == null
        ? _emptyConfig
        : await _read(p.join(repoRoot, _configFileName));

    return (
      exclude: [...repoConfig.exclude, ...packageConfig.exclude],
      threshold: packageConfig.threshold,
    );
  }

  /// The nearest folder above [packagePath] that holds a `.git` entry (a
  /// folder, or a file in a worktree), or `null` if there's none.
  String? _findRepoRoot(String packagePath) {
    var dir = p.dirname(p.normalize(p.absolute(packagePath)));
    while (true) {
      if (FileSystemEntity.typeSync(p.join(dir, '.git')) !=
          FileSystemEntityType.notFound) {
        return dir;
      }
      final parent = p.dirname(dir);
      if (parent == dir) return null;
      dir = parent;
    }
  }

  Future<CoverageConfig> _read(String path) async {
    final file = File(path);
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

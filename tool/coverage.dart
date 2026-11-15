// Checks one package's line coverage against its threshold.
//
// Usage, from the package's folder (Melos runs it in each one):
//   dart run <repo>/tool/coverage.dart [--threshold <percent>]
//
// - Every library in lib/ counts, not only those a test imports: a test
//   importing them all is written for the run and deleted afterwards.
// - Excluded files: the patterns under `exclude:` in the repository root's
//   coverage.yaml, then the package's own coverage.yaml.
// - The package's coverage.yaml `threshold:` overrides --threshold
//   (default 100). A package with nothing left to measure passes.
//
// Requires lcov, and for a pure-Dart package the coverage package activated
// globally (`dart pub global activate coverage`).

import 'dart:io';

import 'package:path/path.dart' as p;

import 'src/coverage/coverage_config.dart';
import 'src/coverage/lcov.dart';
import 'src/coverage/package.dart';
import 'src/coverage/paths.dart';
import 'src/coverage/report.dart';
import 'src/coverage/test_runner.dart';

Future<void> main(List<String> args) async {
  final package = Package.current();
  final packageConfig = readConfig(p.join(package.dir, configFileName));
  final repoConfig = readConfig(p.join(repoRoot(), configFileName));

  await collectCoverage(package);
  await removeExcluded(combinedExclude(repoConfig, packageConfig));

  final passed = report(
    package.name,
    lineCounts(File(p.join(package.dir, lcovPath))),
    requiredThreshold(packageConfig, args),
  );
  if (!passed) exit(1);
}

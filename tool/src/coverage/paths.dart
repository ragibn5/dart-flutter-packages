import 'dart:io';

import 'package:path/path.dart' as p;

/// A package's and the repository root's coverage settings file.
const configFileName = 'coverage.yaml';

/// Where, in a package, the run's imports test is written.
const importsTestPath = 'test/coverage_imports_test.dart';

/// Where, in a package, the lcov report is written.
const lcovPath = 'coverage/lcov.info';

/// The repository root: the folder above the running script's tool/.
String repoRoot() => p.dirname(p.dirname(Platform.script.toFilePath()));

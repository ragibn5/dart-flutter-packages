import 'dart:io';

import 'lcov.dart';

/// Prints the package's result, and the lines it missed when it fails;
/// whether it met [threshold].
bool report(String packageName, LineCounts counts, double threshold) {
  final passed = counts.percent >= threshold;
  stdout.writeln(
    '${passed ? '✅' : '❌'} $packageName: '
    '${counts.percent.toStringAsFixed(1)}% (required $threshold%)',
  );
  if (!passed) {
    stdout.writeln('Uncovered lines:');
    counts.uncovered.forEach((line) => stdout.writeln('  $line'));
  }
  return passed;
}

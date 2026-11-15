import 'dart:io';

import 'lcov.dart';

/// Prints the package's result; whether it met [threshold].
bool report(String packageName, LineCounts counts, double threshold) {
  final passed = counts.percent >= threshold;
  stdout.writeln(
    '${passed ? '✅' : '❌'} $packageName: '
    '${counts.percent.toStringAsFixed(1)}% (required $threshold%)',
  );
  return passed;
}

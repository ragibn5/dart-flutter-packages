import 'dart:io';

import 'paths.dart';
import 'process.dart';

/// Leaves the files matching [exclude] out of the lcov report.
Future<void> removeExcluded(List<String> exclude) async {
  if (exclude.isEmpty) return;
  await run('lcov', [
    '--remove', lcovPath, ...exclude, '--output-file', lcovPath,
    // An exclusion that matches nothing in this package isn't an error.
    '--ignore-errors', 'unused,empty',
  ]);
}

/// The line counts the lcov report at [lcov] sums to.
LineCounts lineCounts(File lcov) {
  final lines = _readLcov(lcov);
  return LineCounts(
    found: _sumRecords(lines, 'LF:'),
    hit: _sumRecords(lines, 'LH:'),
    uncovered: _uncoveredLines(lines),
  );
}

/// Every `<file>:<line>` the lcov [lines] record with no hits.
List<String> _uncoveredLines(List<String> lines) {
  final uncovered = <String>[];
  var file = '';
  for (final line in lines) {
    if (line.startsWith('SF:')) file = line.substring(3);
    if (!line.startsWith('DA:')) continue;
    final [number, hits, ...] = line.substring(3).split(',');
    if (hits == '0') uncovered.add('$file:$number');
  }
  return uncovered;
}

List<String> _readLcov(File lcov) {
  if (!lcov.existsSync()) fail('No coverage data at ${lcov.path}');
  return lcov.readAsLinesSync();
}

/// The sum of the counts on the lcov [lines] starting with [prefix].
int _sumRecords(List<String> lines, String prefix) => lines
    .where((line) => line.startsWith(prefix))
    .map((line) => int.parse(line.substring(prefix.length)))
    .fold(0, (sum, count) => sum + count);

/// The line counts an lcov report sums to.
class LineCounts {
  /// Lines that can be measured.
  final int found;

  /// Measured lines the tests ran.
  final int hit;

  /// The measured lines the tests didn't run, as `<file>:<line>`.
  final List<String> uncovered;

  const LineCounts({
    required this.found,
    required this.hit,
    required this.uncovered,
  });

  /// The line coverage in percent; 100 with no measurable lines, as nothing
  /// is uncovered then.
  double get percent => found == 0 ? 100 : hit / found * 100;
}

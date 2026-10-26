// Experiment-only helpers for profiling the read pipeline. Mirrors the
// platform side's `Timing.kt`; everything is printed with a `[MPTiming]`
// prefix.

// ignore_for_file: avoid_print

/// Runs [call] and prints how long it took, in microseconds.
T timedSync<T>(String label, T Function() call) {
  final stopwatch = Stopwatch()..start();
  try {
    return call();
  } finally {
    print('[MPTiming] $label: ${stopwatch.elapsedMicroseconds}us');
  }
}

/// Awaits [call] and prints how long it took, in microseconds.
Future<T> timed<T>(String label, Future<T> Function() call) async {
  final stopwatch = Stopwatch()..start();
  try {
    return await call();
  } finally {
    print('[MPTiming] $label: ${stopwatch.elapsedMicroseconds}us');
  }
}

/// Prints the time between consecutive [lap] calls, for spans that a single
/// closure can't wrap, such as a `yield`.
///
/// The first lap is measured from construction.
final class Laps {
  final String _label;
  final Stopwatch _stopwatch = Stopwatch()..start();

  Laps(this._label);

  void lap(String name) {
    print('[MPTiming] $_label $name: ${_stopwatch.elapsedMicroseconds}us');
    _stopwatch.reset();
  }
}

/// Prints the wall-clock time in milliseconds.
///
/// Comparable with the platform side's marks, which read the same clock.
void logMark(String label) {
  print('[MPTiming] $label at ${DateTime.now().millisecondsSinceEpoch}ms');
}

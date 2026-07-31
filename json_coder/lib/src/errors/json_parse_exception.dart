/// Thrown when decoding a JSON value fails.
///
/// Carries the [path] from the root of the decoded value to the failing
/// value.
class JsonParseException implements Exception {
  JsonParseException(this.message, [this.path = const []]);

  /// A description of the expected value and the value that was found.
  final String message;

  /// The path segments (string map keys and int list indices) from the
  /// root of the decoded value to the failing value.
  ///
  /// Empty when the failure is at the root of the decoded value.
  final List<Object?> path;

  @override
  String toString() {
    if (path.isEmpty) {
      return message;
    }

    final buffer = StringBuffer(message)..write(r' at $');
    for (final segment in path) {
      buffer
        ..write('[')
        ..write(segment is String ? "'$segment'" : '$segment')
        ..write(']');
    }
    return buffer.toString();
  }
}

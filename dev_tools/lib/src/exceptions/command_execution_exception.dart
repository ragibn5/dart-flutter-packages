/// Base for every exception this tool throws.
///
/// [message] is the raw, unprefixed description — safe to reuse
/// programmatically (e.g. embedded in a bullet list). The "Error: " prefix
/// shown to a human is added once here, in [toString], rather than by each
/// throw site.
abstract class CommandExecutionException implements Exception {
  String get message;

  const CommandExecutionException();

  @override
  String toString() => 'Error: $message';
}

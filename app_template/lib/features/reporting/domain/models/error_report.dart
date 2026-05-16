class ErrorReport {
  final String source;
  final String description;
  final StackTrace stackTrace;

  ErrorReport({
    required this.source,
    required this.description,
    required this.stackTrace,
  });
}

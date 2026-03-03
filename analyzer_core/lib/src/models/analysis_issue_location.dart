class AnalysisIssueLocation {
  /// The absolute path to the file containing the issue.
  final String filePath;

  /// The character offset within the file where the issue begins.
  /// Measured from the start of the file (0-indexed).
  final int offset;

  /// The number of characters involved in the issue.
  /// The issue spans from [offset] to [offset]+[length]-1.
  final int length;

  /// The 0-indexed line number where the issue begins.
  final int startLine;

  /// The 0-indexed column number where the issue begins.
  /// This is relative to the start of the line indicated by [startLine].
  final int startColumn;

  AnalysisIssueLocation({
    required this.filePath,
    required this.offset,
    required this.length,
    required this.startLine,
    required this.startColumn,
  });
}

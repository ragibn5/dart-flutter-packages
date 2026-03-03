/// Represents the severity level of static analysis issues.
///
/// These levels determine how analysis tools should present issues to users
/// and may affect build processes (e.g., whether errors fail builds).
enum AnalysisIssueSeverity {
  /// Informational findings that don't affect code correctness.
  ///
  /// These typically represent style suggestions, best practices,
  /// or non-critical improvements. Example: "Consider using final for variables
  /// that aren't reassigned."
  INFO,

  /// Potential problems that may lead to issues but won't necessarily cause
  /// runtime failures.
  ///
  /// Warnings indicate code that works but might be problematic. Example:
  /// "Unused import that could be removed."
  WARNING,

  /// Critical issues that will cause problems and must be fixed.
  ///
  /// Errors represent definite problems that will cause runtime failures or
  /// unexpected behavior. Example: "Type mismatch in assignment."
  ERROR,
}

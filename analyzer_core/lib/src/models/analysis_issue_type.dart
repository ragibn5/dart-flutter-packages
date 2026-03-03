/// Categorizes the nature of static analysis issues.
///
/// These types help tools classify issues and determine appropriate handling.
/// The values correspond to the Dart analyzer's issue type system.
enum AnalysisIssueType {
  /// Errors that would occur in Dart's checked mode (now deprecated).
  ///
  /// These were runtime type checking errors that have been superseded
  /// by Dart's sound null safety and static type system.
  CHECKED_MODE_COMPILE_TIME_ERROR,

  /// Errors detected during static analysis that prevent code execution.
  ///
  /// Example: Undefined identifier references or syntax errors.
  COMPILE_TIME_ERROR,

  /// Suggestions for code improvements that don't affect functionality.
  ///
  /// Less severe than warnings, these often represent style recommendations
  /// or opportunities for optimization.
  HINT,

  /// Issues identified by lint rules (style and best practice violations).
  ///
  /// These are configurable rules that enforce code style and maintainability.
  /// Example: "Prefer using const constructors for immutable objects."
  LINT,

  /// Warnings about potentially unsafe type operations.
  ///
  /// These indicate places where type safety might be compromised.
  /// Example: Implicit downcasts of dynamic types.
  STATIC_TYPE_WARNING,

  /// General static analysis warnings not specifically about types.
  ///
  /// These catch potential issues that aren't strictly type-related.
  /// Example: Dead code or unreachable statements.
  STATIC_WARNING,

  /// Errors in code syntax that prevent parsing.
  ///
  /// These occur when code doesn't conform to Dart's grammatical structure.
  /// Example: Missing parentheses or semicolons.
  SYNTACTIC_ERROR,

  /// Markers for unfinished code portions.
  ///
  /// These are developer reminders that shouldn't appear in production code.
  TODO,
}

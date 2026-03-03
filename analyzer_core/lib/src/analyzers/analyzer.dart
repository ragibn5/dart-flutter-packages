import 'package:analyzer/dart/analysis/analysis_context.dart';
import 'package:analyzer_core/analyzer_core.dart';
import 'package:analyzer_core/src/models/analysis_issue.dart';

/// Base class for all analyzers.
abstract class Analyzer {
  /// Name of the analyzer.
  /// May be used to identify in logs and other places.
  String get analyzerName;

  /// Analyzes the file and returns the list of [AnalysisIssue].
  Future<List<AnalysisIssue>> analyzeFile(
    AnalysisContext context,
    String absoluteFilePath,
  );
}

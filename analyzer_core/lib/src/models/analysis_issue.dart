import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer_core/src/models/analysis_issue_data.dart';
import 'package:analyzer_core/src/models/analysis_issue_location.dart';

/// Represents an issue detected by a code analyzer.
/// This class encapsulates all information about a detected code issue,
/// including its location and severity.
class AnalysisIssue {
  final AnalysisIssueData data;
  final AnalysisIssueLocation location;

  /// Creates a new [AnalysisIssue] with the specified properties.
  AnalysisIssue({required this.data, required this.location});

  factory AnalysisIssue.fromNode({
    required ResolvedUnitResult analysisResult,
    required AstNode node,
    required AnalysisIssueData issueData,
  }) {
    final location = analysisResult.unit.lineInfo.getLocation(node.offset);
    final issueLocation = AnalysisIssueLocation(
      filePath: analysisResult.path,
      offset: node.offset,
      length: node.length,
      startLine: location.lineNumber,
      startColumn: location.columnNumber,
    );
    return AnalysisIssue(data: issueData, location: issueLocation);
  }

  factory AnalysisIssue.fromToken({
    required ResolvedUnitResult analysisResult,
    required Token token,
    required AnalysisIssueData issueData,
  }) {
    final location = analysisResult.unit.lineInfo.getLocation(token.offset);
    final issueLocation = AnalysisIssueLocation(
      filePath: analysisResult.path,
      offset: token.offset,
      length: token.length,
      startLine: location.lineNumber,
      startColumn: location.columnNumber,
    );
    return AnalysisIssue(data: issueData, location: issueLocation);
  }

  @override
  String toString() => 'AnalysisIssue [Code: ${data.code}]:\n'
      '- File: ${location.filePath}\n'
      // ignore: lines_longer_than_80_chars
      '- Location: (Line: ${location.startLine} , Column: ${location.startColumn})\n'
      '- Severity: ${data.severity.name}\n'
      '- TYPE: ${data.issueType.name}\n'
      '- Message: ${data.message}\n';
}

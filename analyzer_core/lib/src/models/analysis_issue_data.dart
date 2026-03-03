import 'dart:io';

import 'package:analyzer_core/src/models/analysis_isIssue_severity.dart';
import 'package:analyzer_core/src/models/analysis_issue_type.dart';

class AnalysisIssueData {
  /// The unique code identifying the type of issue.
  /// This is typically used for filtering or looking up
  /// documentation about the issue.
  final String code;

  /// The human-readable message describing the issue.
  final String message;

  /// The type of the issue.
  final AnalysisIssueType issueType;

  /// The severity level of the issue.
  final AnalysisIssueSeverity severity;

  const AnalysisIssueData({
    required this.code,
    required this.message,
    required this.issueType,
    required this.severity,
  });

  AnalysisIssueData withPrefixMessage(
    String prefixMessage, {
    String? customSeparator,
  }) {
    final platformLineSeparator = Platform.lineTerminator;
    final separator =
        customSeparator ?? '$platformLineSeparator$platformLineSeparator';

    return copyWith(message: '$prefixMessage$separator$message');
  }

  AnalysisIssueData copyWith({
    String? code,
    String? message,
    AnalysisIssueType? issueType,
    AnalysisIssueSeverity? severity,
  }) {
    return AnalysisIssueData(
      code: code ?? this.code,
      message: message ?? this.message,
      issueType: issueType ?? this.issueType,
      severity: severity ?? this.severity,
    );
  }
}

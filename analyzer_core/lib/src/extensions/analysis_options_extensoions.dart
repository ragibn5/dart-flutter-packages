import 'package:analyzer/dart/analysis/analysis_options.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer_core/src/models/analysis_isIssue_severity.dart';

extension AnalysisOptionsExtensions on AnalysisOptions {
  AnalysisIssueSeverity getSeverity(
    String ruleName, {
    required AnalysisIssueSeverity defaultSeverity,
  }) {
    final rule = lintRules.where((rule) => rule.name == ruleName).firstOrNull;

    final errorSeverity = rule?.lintCode.errorSeverity;
    switch (errorSeverity) {
      case ErrorSeverity.INFO:
        return AnalysisIssueSeverity.INFO;
      case ErrorSeverity.WARNING:
        return AnalysisIssueSeverity.WARNING;
      case ErrorSeverity.ERROR:
        return AnalysisIssueSeverity.ERROR;
      default:
        return defaultSeverity;
    }
  }
}

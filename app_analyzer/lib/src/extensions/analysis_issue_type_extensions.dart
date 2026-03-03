import 'package:analyzer_core/analyzer_core.dart';
import 'package:analyzer_plugin/protocol/protocol_common.dart';

extension AnalysisIssueSeverityExtensions on AnalysisIssueType {
  AnalysisErrorType toAnalysisErrorType() {
    return switch (this) {
      AnalysisIssueType.CHECKED_MODE_COMPILE_TIME_ERROR =>
        AnalysisErrorType.CHECKED_MODE_COMPILE_TIME_ERROR,
      AnalysisIssueType.COMPILE_TIME_ERROR =>
        AnalysisErrorType.CHECKED_MODE_COMPILE_TIME_ERROR,
      AnalysisIssueType.HINT =>
        AnalysisErrorType.CHECKED_MODE_COMPILE_TIME_ERROR,
      AnalysisIssueType.LINT =>
        AnalysisErrorType.CHECKED_MODE_COMPILE_TIME_ERROR,
      AnalysisIssueType.STATIC_TYPE_WARNING =>
        AnalysisErrorType.CHECKED_MODE_COMPILE_TIME_ERROR,
      AnalysisIssueType.STATIC_WARNING =>
        AnalysisErrorType.CHECKED_MODE_COMPILE_TIME_ERROR,
      AnalysisIssueType.SYNTACTIC_ERROR =>
        AnalysisErrorType.CHECKED_MODE_COMPILE_TIME_ERROR,
      AnalysisIssueType.TODO =>
        AnalysisErrorType.CHECKED_MODE_COMPILE_TIME_ERROR,
    };
  }
}

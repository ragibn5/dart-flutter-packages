import 'package:analyzer_core/analyzer_core.dart';
import 'package:analyzer_plugin/protocol/protocol_common.dart';

extension AnalysisIssueSeverityExtensions on AnalysisIssueSeverity {
  AnalysisErrorSeverity toAnalysisErrorSeverity() {
    return switch (this) {
      AnalysisIssueSeverity.INFO => AnalysisErrorSeverity.INFO,
      AnalysisIssueSeverity.WARNING => AnalysisErrorSeverity.WARNING,
      AnalysisIssueSeverity.ERROR => AnalysisErrorSeverity.ERROR,
    };
  }
}

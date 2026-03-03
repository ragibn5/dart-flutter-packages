import 'package:analyzer_core/analyzer_core.dart';
import 'package:analyzer_plugin/protocol/protocol_common.dart';

extension AnalysisIssueLocationExtensions on AnalysisIssueLocation {
  Location toProtocolLocation() {
    return Location(filePath, offset, length, startLine, startColumn);
  }
}

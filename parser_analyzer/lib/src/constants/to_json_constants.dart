import 'package:analyzer_core/analyzer_core.dart';

const _MISSING_TO_JSON_CODE = 'missing_to_json_method';
const _INVALID_TO_JSON_CODE = 'invalid_to_json_method';
const _TO_JSON_METHOD_SPEC_ERROR_MESSAGE = '''
The class must contain a public encoder method with following specs:
- Name of the method must be `toJson`
- Takes no parameters
- Returns `Map<String, dynamic>`
- That is, the final signature is `Map<String, dynamic> toJson() { ... }`
''';

const DEFAULT_MISSING_TO_JSON_METHOD_ISSUE_DATA = AnalysisIssueData(
  code: _MISSING_TO_JSON_CODE,
  message: _TO_JSON_METHOD_SPEC_ERROR_MESSAGE,
  severity: AnalysisIssueSeverity.ERROR,
  issueType: AnalysisIssueType.COMPILE_TIME_ERROR,
);
const DEFAULT_INVALID_TO_JSON_METHOD_ISSUE_DATA = AnalysisIssueData(
  code: _INVALID_TO_JSON_CODE,
  message: _TO_JSON_METHOD_SPEC_ERROR_MESSAGE,
  severity: AnalysisIssueSeverity.ERROR,
  issueType: AnalysisIssueType.COMPILE_TIME_ERROR,
);

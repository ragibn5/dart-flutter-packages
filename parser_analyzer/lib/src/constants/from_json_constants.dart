import 'package:analyzer_core/analyzer_core.dart';

const _MISSING_FROM_JSON_CODE = 'missing_from_json_constructor';
const _INVALID_FROM_JSON_CODE = 'invalid_from_json_constructor';
const _FROM_JSON_CONSTRUCTOR_SPEC_ERROR_MESSAGE = '''
The class must contain a factory constructor with following specs:
- Name of the factory constructor must be 'fromJson'
- Takes a single parameter of type `Map<String, dynamic>`
- Returns an instance of the class
- That is, the final signature is `factory MyModel.fromJson(Map<String, dynamic> json) { ... }`
''';

const DEFAULT_MISSING_FROM_JSON_METHOD_ISSUE_DATA = AnalysisIssueData(
  code: _MISSING_FROM_JSON_CODE,
  message: _FROM_JSON_CONSTRUCTOR_SPEC_ERROR_MESSAGE,
  severity: AnalysisIssueSeverity.ERROR,
  issueType: AnalysisIssueType.COMPILE_TIME_ERROR,
);
const DEFAULT_INVALID_FROM_JSON_METHOD_ISSUE_DATA = AnalysisIssueData(
  code: _INVALID_FROM_JSON_CODE,
  message: _FROM_JSON_CONSTRUCTOR_SPEC_ERROR_MESSAGE,
  severity: AnalysisIssueSeverity.ERROR,
  issueType: AnalysisIssueType.COMPILE_TIME_ERROR,
);

import 'package:analysis_server_core/analysis_server_core.dart';
import 'package:json_parser_analyzer/src/models/json_parser_lint_config.dart';
import 'package:json_parser_analyzer/src/rules/json_parser_requirement_rule/json_parser_requirement_rule.dart';
import 'package:json_parser_analyzer/src/rules/json_parser_requirement_rule/json_parser_requirement_visitor.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class _FakeJsonParserRequirementRuleVisitor extends Fake
    implements JsonParserRequirementRuleVisitor {}

class _MockSessionDataManager extends Mock implements SessionDataManager {}

class _MockRuleContext extends Mock implements RuleContext {}

class _MockRuleContextUnit extends Mock implements RuleContextUnit {}

class _MockAnalyzerFile extends Mock implements AnalyzerFile {}

class _MockRuleVisitorRegistry extends Mock implements RuleVisitorRegistry {}

class _MockRuleSessionContext extends Mock
    implements RuleSessionContext<JsonParserLintConfig> {}

class _MockJsonParserLintConfig extends Mock implements JsonParserLintConfig {}

class _MockSessionLogger extends Mock implements SessionLogger {}

void main() {
  const contextUnitLocation = 'lib/src/models/my_model.dart';

  late _MockSessionDataManager mockSessionDataManager;
  late _MockRuleContext mockRuleContext;
  late _MockRuleContextUnit mockRuleContextUnit;
  late _MockAnalyzerFile mockContextUnitFile;
  late _MockRuleVisitorRegistry mockRuleVisitorRegistry;
  late _MockRuleSessionContext mockRuleSessionContext;
  late _MockJsonParserLintConfig mockConfig;
  late _MockSessionLogger mockSessionLogger;

  late JsonParserRequirementRule sut;

  setUpAll(() {
    registerFallbackValue(_FakeJsonParserRequirementRuleVisitor());
  });

  setUp(() {
    mockSessionDataManager = _MockSessionDataManager();
    mockRuleContext = _MockRuleContext();
    mockRuleContextUnit = _MockRuleContextUnit();
    mockContextUnitFile = _MockAnalyzerFile();
    mockRuleVisitorRegistry = _MockRuleVisitorRegistry();
    mockRuleSessionContext = _MockRuleSessionContext();
    mockConfig = _MockJsonParserLintConfig();
    mockSessionLogger = _MockSessionLogger();

    sut = JsonParserRequirementRule(mockSessionDataManager);

    when(() => mockRuleContext.definingUnit).thenReturn(mockRuleContextUnit);
    when(() => mockRuleContextUnit.file).thenReturn(mockContextUnitFile);
    when(() => mockContextUnitFile.path).thenReturn(contextUnitLocation);
    when(() => mockRuleSessionContext.config).thenReturn(mockConfig);
    when(() => mockRuleSessionContext.logger).thenReturn(mockSessionLogger);
    when(
      () => mockSessionLogger.logInfo(
        tag: any(named: 'tag'),
        message: any(named: 'message'),
      ),
    ).thenAnswer((_) {});
  });

  test('Visitor is registered correctly for a source file', () {
    sut.registerSessionedNodeProcessors(
      mockRuleContext,
      mockRuleVisitorRegistry,
      mockRuleSessionContext,
    );

    verify(
      () => mockSessionLogger.logInfo(
        tag: any(named: 'tag'),
        message: any(named: 'message'),
      ),
    ).called(1);

    verify(
      () => mockRuleVisitorRegistry.addAnnotation(
        sut,
        any(
          that: isA<JsonParserRequirementRuleVisitor>()
              .having((v) => v.rule, 'rule', sut)
              .having(
                (v) => v.sessionContext,
                'sessionContext',
                mockRuleSessionContext,
              ),
        ),
      ),
    ).called(1);
  });
}

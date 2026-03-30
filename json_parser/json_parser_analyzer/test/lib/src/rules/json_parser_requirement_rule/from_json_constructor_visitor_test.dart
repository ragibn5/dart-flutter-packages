// ignore_for_file: lines_longer_than_80_chars, avoid_positional_boolean_parameters

import 'package:analysis_plugin_test_helper/analysis_plugin_test_helper.dart';
import 'package:analysis_server_core/analysis_server_core.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:json_parser_analyzer/src/models/json_parser_analyzer_config.dart';
import 'package:json_parser_analyzer/src/rules/json_parser_requirement_rule/from_json_constructor_visitor.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class _FakeToken extends Fake implements Token {}

class _MockAnalysisRule extends Mock implements AnalysisRule {}

class _MockRuleSessionContext extends Mock
    implements RuleSessionContext<JsonParserAnalyzerConfig> {}

class _MockCollectionTypeResolver extends Mock
    implements CollectionTypeResolver {}

class _MockLogger extends Mock implements SessionLogger {}

void main() {
  final fakeToken = _FakeToken();
  final fakeTypeAnnotation = parseString(
    content: '@deprecated class Foo {}',
  ).unit.declarations.first.metadata.first;

  final visitorConfig = FromJsonConstructorVisitorConfig(
    wrongParamCountContextMessage: 'rcm-1',
    wrongParamDeclarationTypeContextMessage: 'rcm-2',
    invalidParamTypeContextMessage: 'rcm-3',
  );

  final dartResolver = DartUnitResolver();

  late _MockLogger mockLogger;
  late _MockAnalysisRule mockRule;
  late _MockRuleSessionContext mockSessionContext;
  late _MockCollectionTypeResolver mockCollectionTypeResolver;

  late FromJsonConstructorVisitor sut;

  void verifyNoReports(_MockAnalysisRule rule) {
    verifyNever(
      () => rule.reportAtToken(any(), arguments: any(named: 'arguments')),
    );
    verifyNever(
      () => rule.reportAtNode(any(), arguments: any(named: 'arguments')),
    );
  }

  void stubCollectionTypeResolverIsMapOf({required bool returnValue}) {
    when(
      () => mockCollectionTypeResolver.isMapOf(
        any(),
        keyType: any(named: 'keyType'),
        valueType: any(named: 'valueType'),
        mapNullable: any(named: 'mapNullable'),
      ),
    ).thenReturn(returnValue);
  }

  setUpAll(() {
    registerFallbackValue(fakeToken);
    registerFallbackValue(fakeTypeAnnotation);
  });

  setUp(() async {
    await dartResolver.setUp();

    mockLogger = _MockLogger();
    mockRule = _MockAnalysisRule();
    mockSessionContext = _MockRuleSessionContext();
    mockCollectionTypeResolver = _MockCollectionTypeResolver();

    sut = FromJsonConstructorVisitor.test(
      mockRule,
      visitorConfig,
      mockSessionContext,
      mockCollectionTypeResolver,
    );

    when(() => mockSessionContext.logger).thenReturn(mockLogger);
    when(
      () => mockLogger.logInfo(
        tag: any(named: 'tag'),
        message: any(named: 'message'),
      ),
    ).thenReturn(null);
    when(
      () => mockLogger.logWarning(
        tag: any(named: 'tag'),
        message: any(named: 'message'),
      ),
    ).thenReturn(null);

    when(
      () => mockRule.reportAtToken(any(), arguments: any(named: 'arguments')),
    ).thenReturn(null);
    when(
      () => mockRule.reportAtNode(any(), arguments: any(named: 'arguments')),
    ).thenReturn(null);

    stubCollectionTypeResolverIsMapOf(returnValue: true);
  });

  tearDown(() async {
    await dartResolver.tearDown();
  });

  test('Reports when fromJson factory takes in no params', () async {
    const content = '''
    class MyModel {
      factory MyModel.fromJson() => MyModel();
      Map<String, dynamic> toJson() => {};
    }
    ''';

    final constructorDeclaration = getParsedFactoryConstructorDeclaration(
      content,
      'fromJson',
    );

    sut.visit(constructorDeclaration);

    verify(
      () => mockRule.reportAtNode(
        any(),
        arguments: [visitorConfig.wrongParamCountContextMessage],
      ),
    ).called(1);
  });

  test('Reports when fromJson factory takes in more than one params', () async {
    const content = '''
    class MyModel {
      factory MyModel.fromJson(Map<String, dynamic> map1, Map<String, dynamic> map2) => MyModel();
      Map<String, dynamic> toJson() => {};
    }
    ''';

    final constructorDeclaration = getParsedFactoryConstructorDeclaration(
      content,
      'fromJson',
    );

    sut.visit(constructorDeclaration);

    verify(
      () => mockRule.reportAtNode(
        any(),
        arguments: [visitorConfig.wrongParamCountContextMessage],
      ),
    ).called(1);
  });

  test('Reports when fromJson factory takes in named param', () async {
    const content = '''
    class MyModel {
      factory MyModel.fromJson({Map<String, dynamic> map}) => MyModel();
      Map<String, dynamic> toJson() => {};
    }
    ''';

    final constructorDeclaration = getParsedFactoryConstructorDeclaration(
      content,
      'fromJson',
    );

    sut.visit(constructorDeclaration);

    verify(
      () => mockRule.reportAtNode(
        any(),
        arguments: [visitorConfig.wrongParamDeclarationTypeContextMessage],
      ),
    ).called(1);
  });

  test(
    'Reports when fromJson factory takes parameter type other that Map<String, dynamic/Object?>',
    () async {
      stubCollectionTypeResolverIsMapOf(returnValue: false);

      const content = '''
      class MyModel {
        factory MyModel.fromJson(Map<String, String> map) => MyModel();
        Map<String, dynamic> toJson() => {};
      }
      ''';

      final constructorDeclaration = getParsedFactoryConstructorDeclaration(
        content,
        'fromJson',
      );

      sut.visit(constructorDeclaration);

      verify(
        () => mockRule.reportAtNode(
          any(),
          arguments: [visitorConfig.invalidParamTypeContextMessage],
        ),
      ).called(1);
    },
  );

  test(
    'Reports nothing when fromJson factory takes correct parameter type (Map<String, dynamic/Object?>)',
    () async {
      const content = '''
      class MyModel {
        factory MyModel.fromJson(Map<String, dynamic> map) => MyModel();
        Map<String, dynamic> toJson() => {};
      }
      ''';

      final constructorDeclaration = getParsedFactoryConstructorDeclaration(
        content,
        'fromJson',
      );

      sut.visit(constructorDeclaration);

      verifyNoReports(mockRule);
    },
  );

  test(
    'Reports nothing when fromJson factory uses typedef for parameter type (not mocking CollectionTypeResolver)',
    () async {
      final localSUT = FromJsonConstructorVisitor.test(
        mockRule,
        visitorConfig,
        mockSessionContext,
        CollectionTypeResolverFactory.create(),
      );

      final resolved = await dartResolver.resolveSource('''
      typedef JsonMap = Map<String, dynamic>;
      
      class MyModel {
        factory MyModel.fromJson(JsonMap json) => MyModel();
        Map<String, dynamic> toJson() => {};
      }
      ''');

      final constructorDeclaration = getConstructorDeclaration(
        resolved.unit,
        'fromJson',
      );

      localSUT.visit(constructorDeclaration);

      verifyNoReports(mockRule);
    },
  );
}

// ignore_for_file: lines_longer_than_80_chars, avoid_positional_boolean_parameters

import 'package:analysis_plugin_test_helper/analysis_plugin_test_helper.dart';
import 'package:analysis_server_core/analysis_server_core.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:json_parser_analyzer/src/models/json_parser_analyzer_config.dart';
import 'package:json_parser_analyzer/src/rules/json_parser_requirement_rule/to_json_method_visitor.dart';
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

  final visitorConfig = ToJsonMethodVisitorConfig(
    getterNotAllowedContextMessage: 'rcm-1',
    paramsNotAllowedContextMessage: 'rcm-2',
    missingReturnTypeContextMessage: 'rcm-3',
    invalidReturnTypeContextMessage: 'rcm-4',
  );

  final dartResolver = DartUnitResolver();

  late _MockLogger mockLogger;
  late _MockAnalysisRule mockRule;
  late _MockRuleSessionContext mockSessionContext;
  late _MockCollectionTypeResolver mockCollectionTypeResolver;

  late ToJsonMethodVisitor sut;

  void verifyNoReports(_MockAnalysisRule rule) {
    verifyNever(
      () => rule.reportAtToken(any(), arguments: any(named: 'arguments')),
    );
    verifyNever(
      () => rule.reportAtNode(any(), arguments: any(named: 'arguments')),
    );
  }

  MethodDeclaration findMethodDeclarationFromNode(
    CompilationUnit unit,
    String name,
  ) => unit.declarations
      .whereType<ClassDeclaration>()
      .first
      .members
      .whereType<MethodDeclaration>()
      .firstWhere((m) => m.name.lexeme == name);

  MethodDeclaration findMethodDeclaration(String content, String name) {
    return findMethodDeclarationFromNode(
      parseString(content: content).unit,
      name,
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

    sut = ToJsonMethodVisitor.test(
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

  test('Reports when toJson is a getter', () {
    const content = '''
    class MyModel {
      factory MyModel.fromJson(Map<String, dynamic> json) => MyModel();
      Map<String, dynamic> get toJson => {};
    }
    ''';
    final methodDecl = findMethodDeclaration(content, 'toJson');

    sut.visit(methodDecl);

    verify(
      () => mockRule.reportAtToken(
        any(),
        arguments: [visitorConfig.getterNotAllowedContextMessage],
      ),
    ).called(1);
  });

  test('Reports when toJson has parameters', () {
    const content = '''
    class MyModel {
      factory MyModel.fromJson(Map<String, dynamic> json) => MyModel();
      Map<String, dynamic> toJson(String extra) => {};
    }
    ''';
    final methodDecl = findMethodDeclaration(content, 'toJson');

    sut.visit(methodDecl);

    verify(
      () => mockRule.reportAtNode(
        any(),
        arguments: [visitorConfig.paramsNotAllowedContextMessage],
      ),
    ).called(1);
  });

  test('Reports when toJson return type is missing', () {
    when(
      () => mockCollectionTypeResolver.isMapOf(
        any(),
        keyType: any(named: 'keyType'),
        valueType: any(named: 'valueType'),
        mapNullable: any(named: 'mapNullable'),
      ),
    ).thenReturn(false);

    const content = '''
    class MyModel {
      factory MyModel.fromJson(Map<String, dynamic> json) => MyModel();
      toJson() => '';
    }
    ''';
    final methodDecl = findMethodDeclaration(content, 'toJson');

    sut.visit(methodDecl);

    verify(
      () => mockRule.reportAtToken(
        any(),
        arguments: [visitorConfig.missingReturnTypeContextMessage],
      ),
    ).called(1);
  });

  test('Reports when toJson returns wrong type', () {
    stubCollectionTypeResolverIsMapOf(returnValue: false);

    const content = '''
    class MyModel {
      factory MyModel.fromJson(Map<String, dynamic> json) => MyModel();
      String toJson() => '';
    }
    ''';
    final methodDecl = findMethodDeclaration(content, 'toJson');

    sut.visit(methodDecl);

    verify(
      () => mockRule.reportAtNode(
        any(),
        arguments: [visitorConfig.invalidReturnTypeContextMessage],
      ),
    ).called(1);
  });

  test(
    'Reports nothing when toJson returns correct type (Map<String, dynamic> or Map<String, Object?>)',
    () async {
      final resolved = await dartResolver.resolveSource('''
      class MyModel {
        factory MyModel.fromJson(Map<String, dynamic> json) => MyModel();
        Map<String, dynamic> toJson() => {};
      }
      ''');

      final methodDecl = findMethodDeclarationFromNode(resolved.unit, 'toJson');

      sut.visit(methodDecl);

      verifyNoReports(mockRule);
    },
  );
}

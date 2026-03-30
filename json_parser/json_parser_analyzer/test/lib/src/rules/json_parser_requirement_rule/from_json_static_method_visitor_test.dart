// ignore_for_file: lines_longer_than_80_chars, avoid_positional_boolean_parameters

import 'package:analysis_plugin_test_helper/analysis_plugin_test_helper.dart';
import 'package:analysis_server_core/analysis_server_core.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:json_parser_analyzer/src/models/json_parser_analyzer_config.dart';
import 'package:json_parser_analyzer/src/rules/json_parser_requirement_rule/from_json_static_method_visitor.dart';
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

  final visitorConfig = FromJsonStaticMethodVisitorConfig(
    getterNotAllowedContextMessage: 'rcm-1',
    missingParamDeclarationContextMessage: 'rcm-2',
    wrongParamCountContextMessage: 'rcm-3',
    wrongParamDeclarationTypeContextMessage: 'rcm-4',
    invalidParamTypeContextMessage: 'rcm-5',
    nonExplicitReturnTypeContextMessage: 'rcm-6',
    nonEnclosingClassTypeReturnContextMessage: 'rcm-7',
  );

  final dartResolver = DartUnitResolver();

  late _MockLogger mockLogger;
  late _MockAnalysisRule mockRule;
  late _MockRuleSessionContext mockSessionContext;
  late _MockCollectionTypeResolver mockCollectionTypeResolver;

  late FromJsonStaticMethodVisitor sut;

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

  ClassDeclaration getClassDeclaration(CompilationUnit unit) {
    return unit.declarations.whereType<ClassDeclaration>().first;
  }

  ClassDeclaration getParsedClassDeclaration(String content) {
    return getClassDeclaration(parseString(content: content).unit);
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

    sut = FromJsonStaticMethodVisitor.test(
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

  test('Reports when fromJson method is a getter', () async {
    const content = '''
    class MyModel {
      static MyModel get fromJson => MyModel();
      Map<String, dynamic> toJson() => {};
    }
    ''';

    final classDeclaration = getParsedClassDeclaration(content);
    final methodDeclaration = getParsedMethodDeclaration(content, 'fromJson');

    sut.visit(methodDeclaration, classDeclaration);

    verify(
      () => mockRule.reportAtToken(
        any(),
        arguments: [visitorConfig.getterNotAllowedContextMessage],
      ),
    ).called(1);
  });

  test('Reports when fromJson method takes in no params', () async {
    const content = '''
    class MyModel {
      static MyModel fromJson() => MyModel();
      Map<String, dynamic> toJson() => {};
    }
    ''';

    final classDeclaration = getParsedClassDeclaration(content);
    final methodDeclaration = getParsedMethodDeclaration(content, 'fromJson');

    sut.visit(methodDeclaration, classDeclaration);

    verify(
      () => mockRule.reportAtNode(
        any(),
        arguments: [visitorConfig.wrongParamCountContextMessage],
      ),
    ).called(1);
  });

  test('Reports when fromJson method takes in more than one params', () async {
    const content = '''
    class MyModel {
      static MyModel fromJson(Map<String, dynamic> map1, Map<String, dynamic> map2) => MyModel();
      Map<String, dynamic> toJson() => {};
    }
    ''';

    final classDeclaration = getParsedClassDeclaration(content);
    final methodDeclaration = getParsedMethodDeclaration(content, 'fromJson');

    sut.visit(methodDeclaration, classDeclaration);

    verify(
      () => mockRule.reportAtNode(
        any(),
        arguments: [visitorConfig.wrongParamCountContextMessage],
      ),
    ).called(1);
  });

  test('Reports when fromJson method takes in named param', () async {
    const content = '''
    class MyModel {
      static MyModel fromJson({Map<String, dynamic> map}) => MyModel();
      Map<String, dynamic> toJson() => {};
    }
    ''';

    final classDeclaration = getParsedClassDeclaration(content);
    final methodDeclaration = getParsedMethodDeclaration(content, 'fromJson');

    sut.visit(methodDeclaration, classDeclaration);

    verify(
      () => mockRule.reportAtNode(
        any(),
        arguments: [visitorConfig.wrongParamDeclarationTypeContextMessage],
      ),
    ).called(1);
  });

  test(
    'Reports when fromJson method takes parameter type other that Map<String, dynamic/Object?>',
    () async {
      stubCollectionTypeResolverIsMapOf(returnValue: false);

      const content = '''
      class MyModel {
        static MyModel fromJson(Map<String, String> map) => MyModel();
        Map<String, dynamic> toJson() => {};
      }
      ''';

      final classDeclaration = getParsedClassDeclaration(content);
      final methodDeclaration = getParsedMethodDeclaration(content, 'fromJson');

      sut.visit(methodDeclaration, classDeclaration);

      verify(
        () => mockRule.reportAtNode(
          any(),
          arguments: [visitorConfig.invalidParamTypeContextMessage],
        ),
      ).called(1);
    },
  );

  test(
    'Reports nothing when fromJson method takes correct parameter type (Map<String, dynamic/Object?>)',
    () async {
      stubCollectionTypeResolverIsMapOf(returnValue: true);

      final resolved = await dartResolver.resolveSource('''
      class MyModel {
        static MyModel fromJson(Map<String, dynamic> map) => MyModel();
        Map<String, dynamic> toJson() => {};
      }
      ''');

      final classDeclaration = getClassDeclaration(resolved.unit);
      final methodDeclaration = findMethodDeclaration(
        resolved.unit,
        'fromJson',
      );

      sut.visit(methodDeclaration!, classDeclaration);

      verifyNoReports(mockRule);
    },
  );

  test(
    'Reports nothing when fromJson method uses typedef for parameter type (not mocking CollectionTypeResolver)',
    () async {
      final localSUT = FromJsonStaticMethodVisitor.test(
        mockRule,
        visitorConfig,
        mockSessionContext,
        CollectionTypeResolverFactory.create(),
      );

      final resolved = await dartResolver.resolveSource('''
      typedef JsonMap = Map<String, dynamic>;
      
      class MyModel {
        static MyModel fromJson(JsonMap json) => MyModel();
        Map<String, dynamic> toJson() => {};
      }
      ''');

      final classDeclaration = getClassDeclaration(resolved.unit);
      final methodDeclaration = findMethodDeclaration(
        resolved.unit,
        'fromJson',
      );

      localSUT.visit(methodDeclaration!, classDeclaration);

      verifyNoReports(mockRule);
    },
  );
}

// ignore_for_file: lines_longer_than_80_chars, unnecessary_lambdas, avoid_positional_boolean_parameters, avoid_redundant_argument_values

import 'package:analysis_plugin_test_helper/analysis_plugin_test_helper.dart';
import 'package:analysis_server_core/analysis_server_core.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:json_parser_analyzer/src/models/json_parser_analyzer_config.dart';
import 'package:json_parser_analyzer/src/rules/json_parser_requirement_rule/from_json_constructor_visitor.dart';
import 'package:json_parser_analyzer/src/rules/json_parser_requirement_rule/from_json_static_method_visitor.dart';
import 'package:json_parser_analyzer/src/rules/json_parser_requirement_rule/json_parser_requirement_visitor.dart';
import 'package:json_parser_analyzer/src/rules/json_parser_requirement_rule/to_json_method_visitor.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class _FakeToken extends Fake implements Token {}

class _MockAnalysisRule extends Mock implements AnalysisRule {}

class _MockRuleSessionContext extends Mock
    implements RuleSessionContext<JsonParserAnalyzerConfig> {}

class _MockLogger extends Mock implements SessionLogger {}

class _MockToJsonMethodVisitor extends Mock implements ToJsonMethodVisitor {}

class _MockFromJsonConstructorVisitor extends Mock
    implements FromJsonConstructorVisitor {}

class _MockFromJsonStaticMethodVisitor extends Mock
    implements FromJsonStaticMethodVisitor {}

void main() {
  final fakeToken = _FakeToken();
  final fakeAnnotation = parseString(
    content: '@deprecated class Foo {}',
  ).unit.declarations.first.metadata.first;
  final visitorConfig = JsonParserRequirementRuleVisitorConfig(
    missingToJsonContextMessage: 'rcm-1',
    missingFromJsonContextMessage: 'rcm-2',
  );

  final dartResolver = DartUnitResolver();

  late _MockLogger mockLogger;
  late _MockAnalysisRule mockRule;
  late _MockRuleSessionContext mockSessionContext;
  late _MockToJsonMethodVisitor mockToJsonMethodVisitor;
  late _MockFromJsonConstructorVisitor mockFromJsonConstructorVisitor;
  late _MockFromJsonStaticMethodVisitor mockFromJsonStaticMethodVisitor;

  late JsonParserRequirementRuleVisitor sut;

  void verifyNoReports(_MockAnalysisRule rule) {
    verifyNever(
      () => rule.reportAtToken(any(), arguments: any(named: 'arguments')),
    );
    verifyNever(
      () => rule.reportAtNode(any(), arguments: any(named: 'arguments')),
    );
  }

  setUpAll(() {
    registerFallbackValue(fakeToken);
    registerFallbackValue(fakeAnnotation);
  });

  setUp(() async {
    await dartResolver.setUp();

    mockLogger = _MockLogger();
    mockRule = _MockAnalysisRule();
    mockSessionContext = _MockRuleSessionContext();
    mockToJsonMethodVisitor = _MockToJsonMethodVisitor();
    mockFromJsonConstructorVisitor = _MockFromJsonConstructorVisitor();
    mockFromJsonStaticMethodVisitor = _MockFromJsonStaticMethodVisitor();

    sut = JsonParserRequirementRuleVisitor.test(
      mockRule,
      visitorConfig,
      mockSessionContext,
      AnnotationTypeResolverFactory.create(),
      mockToJsonMethodVisitor,
      mockFromJsonConstructorVisitor,
      mockFromJsonStaticMethodVisitor,
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
  });

  tearDown(() async {
    await dartResolver.tearDown();
  });

  test('Ignores annotations other than @GenerateJsonParser', () async {
    final resolved = await dartResolver.resolveSource('''
    @SomeOtherAnnotation()
    class Foo {}
    
    class SomeOtherAnnotation {
      const SomeOtherAnnotation();
    }
    ''');
    final annotation = getAnnotation<ClassDeclaration>(
      resolved.unit,
      annotationName: 'SomeOtherAnnotation',
    );

    sut.visitAnnotation(annotation);

    verifyNoReports(mockRule);
  });

  test(
    'Ignores @GenerateJsonParser on a top-level function (non-class)',
    () async {
      final resolved = await dartResolver.resolveSource('''
      @GenerateJsonParser()
      mixin FooMixin {}
      
      class GenerateJsonParser {
        const GenerateJsonParser();
      }
      ''');
      final annotation = getAnnotation<MixinDeclaration>(
        resolved.unit,
        annotationName: 'GenerateJsonParser',
      );

      sut.visitAnnotation(annotation);

      verifyNoReports(mockRule);
    },
  );

  test('Ignores abstract classes annotated with @GenerateJsonParser', () async {
    final resolved = await dartResolver.resolveSource('''
    @GenerateJsonParser()
    abstract class MyModel {}
    
    class GenerateJsonParser {
      const GenerateJsonParser();
    }
    ''');
    final annotation = getAnnotation<ClassDeclaration>(
      resolved.unit,
      annotationName: 'GenerateJsonParser',
    );

    sut.visitAnnotation(annotation);

    verifyNoReports(mockRule);
  });

  test('Reports when toJson is absent', () async {
    final resolved = await dartResolver.resolveSource('''
    @GenerateJsonParser()
    class MyModel {
      factory MyModel.fromJson(Map<String, dynamic> json) => MyModel();
    }
    
    class GenerateJsonParser {
      const GenerateJsonParser();
    }
    ''');
    final annotation = getAnnotation<ClassDeclaration>(
      resolved.unit,
      annotationName: 'GenerateJsonParser',
    );

    sut.visitAnnotation(annotation);

    verify(
      () => mockRule.reportAtToken(
        any(),
        arguments: [visitorConfig.missingToJsonContextMessage],
      ),
    ).called(1);
  });

  test(
    'Reports when both fromJson factory and static method are absent',
    () async {
      final resolved = await dartResolver.resolveSource('''
      @GenerateJsonParser()
      class MyModel {
        Map<String, dynamic> toJson() => {};
      }
      
      class GenerateJsonParser {
        const GenerateJsonParser();
      }
      ''');
      final annotation = getAnnotation<ClassDeclaration>(
        resolved.unit,
        annotationName: 'GenerateJsonParser',
      );

      sut.visitAnnotation(annotation);

      verify(
        () => mockRule.reportAtToken(
          any(),
          arguments: [visitorConfig.missingFromJsonContextMessage],
        ),
      ).called(1);
    },
  );

  test('Reports both missing toJson and missing fromJson', () async {
    final resolved = await dartResolver.resolveSource('''
    @GenerateJsonParser()
    class MyModel {}
    
    class GenerateJsonParser {
      const GenerateJsonParser();
    }
    ''');
    final annotation = getAnnotation<ClassDeclaration>(
      resolved.unit,
      annotationName: 'GenerateJsonParser',
    );

    sut.visitAnnotation(annotation);

    verify(
      () => mockRule.reportAtToken(
        any(),
        arguments: [visitorConfig.missingToJsonContextMessage],
      ),
    ).called(1);
    verify(
      () => mockRule.reportAtToken(
        any(),
        arguments: [visitorConfig.missingFromJsonContextMessage],
      ),
    ).called(1);
  });

  test(
    'Reports both missing toJson and missing fromJson and annotation is a typedef',
    () async {
      final resolved = await dartResolver.resolveSource('''
      typedef GJP = GenerateJsonParser;
      
      @GJP()
      class MyModel {}
      
      class GenerateJsonParser {
        const GenerateJsonParser();
      }
      ''');
      final annotation = getAnnotation<ClassDeclaration>(
        resolved.unit,
        annotationName: 'GenerateJsonParser',
      );

      sut.visitAnnotation(annotation);

      verify(
        () => mockRule.reportAtToken(
          any(),
          arguments: [visitorConfig.missingToJsonContextMessage],
        ),
      ).called(1);
      verify(
        () => mockRule.reportAtToken(
          any(),
          arguments: [visitorConfig.missingFromJsonContextMessage],
        ),
      ).called(1);
    },
  );
}

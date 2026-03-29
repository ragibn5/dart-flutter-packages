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

class _MockAnnotationTypeResolver extends Mock
    implements AnnotationTypeResolver {}

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
    toJsonMethodName: 'toJson',
    fromJsonConstructorName: 'fromJson',
    fromJsonStaticMethodName: 'fromJson',
    missingToJsonContextMessage: 'rcm1-missing toJson method.',
    missingFromJsonContextMessage:
        'rcm2-missing fromJson constructor (or a static method).',
  );

  late _MockLogger mockLogger;
  late _MockAnalysisRule mockRule;
  late _MockRuleSessionContext mockSessionContext;
  late _MockAnnotationTypeResolver mockAnnotationTypeResolver;
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

  setUp(() {
    mockLogger = _MockLogger();
    mockRule = _MockAnalysisRule();
    mockSessionContext = _MockRuleSessionContext();
    mockAnnotationTypeResolver = _MockAnnotationTypeResolver();
    mockToJsonMethodVisitor = _MockToJsonMethodVisitor();
    mockFromJsonConstructorVisitor = _MockFromJsonConstructorVisitor();
    mockFromJsonStaticMethodVisitor = _MockFromJsonStaticMethodVisitor();

    sut = JsonParserRequirementRuleVisitor.test(
      mockRule,
      visitorConfig,
      mockSessionContext,
      mockAnnotationTypeResolver,
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

    when(
      () => mockAnnotationTypeResolver.resolveTypeName(any()),
    ).thenReturn('GenerateJsonParser');
  });

  test('Ignores annotations other than @GenerateJsonParser', () {
    when(
      () => mockAnnotationTypeResolver.resolveTypeName(any()),
    ).thenReturn('SomeOtherAnnotation');

    const content = '''
    @SomeOtherAnnotation()
    class Foo {}
    ''';
    final annotation = parseAnnotation(
      content,
      annotationName: 'SomeOtherAnnotation',
    );
    expect(annotation, isNotNull);

    sut.visitAnnotation(annotation!);

    verify(() => mockAnnotationTypeResolver.resolveTypeName(any())).called(1);
    verifyNoReports(mockRule);
  });

  test('Ignores @GenerateJsonParser on a top-level function (non-class)', () {
    const content = '''
    @GenerateJsonParser()
    mixin FooMixin {}
    ''';
    final unit = parseString(content: content).unit;
    Annotation? annotation;
    for (final decl in unit.declarations) {
      if (decl is MixinDeclaration) {
        annotation = decl.metadata.firstOrNull;
      }
    }

    if (annotation == null) {
      return;
    }

    sut.visitAnnotation(annotation);

    verifyNoReports(mockRule);
  });

  test('Ignores abstract classes annotated with @GenerateJsonParser', () {
    const content = '''
    @GenerateJsonParser()
    abstract class MyModel {}
    ''';
    final annotation = parseValidAnnotation(
      content,
      annotationName: 'GenerateJsonParser',
    );

    sut.visitAnnotation(annotation);

    verifyNoReports(mockRule);
  });

  test('Reports when toJson is absent', () {
    const content = '''
    @GenerateJsonParser()
    class MyModel {
      factory MyModel.fromJson(Map<String, dynamic> json) => MyModel();
    }
    ''';
    final annotation = parseValidAnnotation(
      content,
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

  test('Reports when both fromJson factory and static method are absent', () {
    const content = '''
    @GenerateJsonParser()
    class MyModel {
      Map<String, dynamic> toJson() => {};
    }
    ''';
    final annotation = parseValidAnnotation(
      content,
      annotationName: 'GenerateJsonParser',
    );

    sut.visitAnnotation(annotation);

    verify(
      () => mockRule.reportAtToken(
        any(),
        arguments: [visitorConfig.missingFromJsonContextMessage],
      ),
    ).called(1);
  });

  test('Reports both missing toJson and missing fromJson', () {
    const content = '''
      @GenerateJsonParser()
      class MyModel {}
      ''';
    final annotation = parseValidAnnotation(
      content,
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

  // group('toJson', () {
  //   test('Reports when toJson is a getter', () {
  //     const content = '''
  //     @GenerateJsonParser()
  //     class MyModel {
  //       factory MyModel.fromJson(Map<String, dynamic> json) => MyModel();
  //       Map<String, dynamic> get toJson => {};
  //     }
  //     ''';
  //     final annotation = parseValidAnnotation(
  //       content,
  //       annotationName: 'GenerateJsonParser',
  //     );
  //
  //     sut.visitAnnotation(annotation);
  //
  //     verify(
  //       () => mockRule.reportAtToken(
  //         any(),
  //         arguments: ['toJson method must not be a getter.'],
  //       ),
  //     ).called(1);
  //   });
  //
  //   test('Reports when toJson return type is missing', () {
  //     stubIsMapOf(false);
  //
  //     const content = '''
  //     @GenerateJsonParser()
  //     class MyModel {
  //       factory MyModel.fromJson(Map<String, dynamic> json) => MyModel();
  //       toJson() => '';
  //     }
  //     ''';
  //     final annotation = parseValidAnnotation(
  //       content,
  //       annotationName: 'GenerateJsonParser',
  //     );
  //
  //     sut.visitAnnotation(annotation);
  //
  //     verify(
  //       () => mockRule.reportAtToken(
  //         any(),
  //         arguments: ['toJson method must have an explicit return type.'],
  //       ),
  //     ).called(1);
  //   });
  //
  //   test('Reports when toJson returns wrong type', () {
  //     stubIsMapOf(false);
  //
  //     const content = '''
  //     @GenerateJsonParser()
  //     class MyModel {
  //       factory MyModel.fromJson(Map<String, dynamic> json) => MyModel();
  //       String toJson() => '';
  //     }
  //     ''';
  //     final annotation = parseValidAnnotation(
  //       content,
  //       annotationName: 'GenerateJsonParser',
  //     );
  //
  //     sut.visitAnnotation(annotation);
  //
  //     verify(
  //       () => mockRule.reportAtNode(
  //         any(),
  //         arguments: [
  //           'toJson method must return Map<String, dynamic> or Map<String, Object?>.',
  //         ],
  //       ),
  //     ).called(1);
  //   });
  //
  //   test(
  //     'Reports nothing when toJson returns correct type (Map<String, dynamic> or Map<String, Object?>)',
  //     () async {
  //       final resolved = await dartResolver.resolveSource('''
  //       @GenerateJsonParser()
  //       class MyModel {
  //         factory MyModel.fromJson(Map<String, dynamic> json) => MyModel();
  //         Map<String, dynamic> toJson() => {};
  //       }
  //       ''');
  //
  //       final annotation = resolved.findAnnotation(
  //         annotationName: 'GenerateJsonParser',
  //       );
  //       if (annotation == null) {
  //         fail('Expected annotation to be found');
  //       }
  //
  //       sut.visitAnnotation(annotation);
  //
  //       verifyNoReports(mockRule);
  //     },
  //   );
  //
  //   test('Reports when toJson has parameters', () {
  //     const content = '''
  //     @GenerateJsonParser()
  //     class MyModel {
  //       factory MyModel.fromJson(Map<String, dynamic> json) => MyModel();
  //       Map<String, dynamic> toJson(String extra) => {};
  //     }
  //     ''';
  //     final annotation = parseValidAnnotation(
  //       content,
  //       annotationName: 'GenerateJsonParser',
  //     );
  //
  //     sut.visitAnnotation(annotation);
  //
  //     verify(
  //       () => mockRule.reportAtNode(
  //         any(),
  //         arguments: ['toJson method must not have parameters.'],
  //       ),
  //     ).called(1);
  //   });
  // });
  //
  // group('fromJson', () {
  //   test('Reports when static fromJson has no return type annotation', () {
  //     const content = '''
  //     @GenerateJsonParser()
  //     class MyModel {
  //       static fromJson(Map<String, dynamic> json) => MyModel();
  //       Map<String, dynamic> toJson() => {};
  //     }
  //     ''';
  //     final annotation = parseValidAnnotation(
  //       content,
  //       annotationName: 'GenerateJsonParser',
  //     );
  //
  //     sut.visitAnnotation(annotation);
  //
  //     verify(
  //       () => mockRule.reportAtToken(
  //         any(),
  //         arguments: ['from method must have an explicit return type.'],
  //       ),
  //     ).called(1);
  //   });
  //
  //   test('Reports when static fromJson returns wrong type', () {
  //     const content = '''
  //     @GenerateJsonParser()
  //     class MyModel {
  //       static String fromJson(Map<String, dynamic> json) => '';
  //       Map<String, dynamic> toJson() => {};
  //     }
  //     ''';
  //     final annotation = parseValidAnnotation(
  //       content,
  //       annotationName: 'GenerateJsonParser',
  //     );
  //
  //     sut.visitAnnotation(annotation);
  //
  //     verify(
  //       () => mockRule.reportAtNode(
  //         any(),
  //         arguments: ['fromJson method must return the enclosing class type.'],
  //       ),
  //     ).called(1);
  //   });
  //
  //   test(
  //     'Reports nothing when static fromJson returns correct class type',
  //     () async {
  //       final resolved = await dartResolver.resolveSource('''
  //       @GenerateJsonParser()
  //       class MyModel {
  //         static MyModel fromJson(Map<String, dynamic> json) => MyModel();
  //         Map<String, dynamic> toJson() => {};
  //       }
  //       ''');
  //
  //       final annotation = resolved.findAnnotation(
  //         annotationName: 'GenerateJsonParser',
  //       );
  //       if (annotation == null) {
  //         fail('Expected annotation to be found');
  //       }
  //
  //       sut.visitAnnotation(annotation);
  //
  //       verifyNoReports(mockRule);
  //     },
  //   );
  //
  //   test(
  //     'Reports nothing when static fromJson returns a typedef of self',
  //     () async {
  //       final resolved = await dartResolver.resolveSource('''
  //       typedef Self = MyModel;
  //
  //       @GenerateJsonParser()
  //       class MyModel {
  //         static Self fromJson(Map<String, dynamic> json) => MyModel();
  //         Map<String, dynamic> toJson() => {};
  //       }
  //       ''');
  //
  //       final annotation = resolved.findAnnotation(
  //         annotationName: 'GenerateJsonParser',
  //       );
  //       if (annotation == null) {
  //         fail('Expected annotation to be found');
  //       }
  //
  //       sut.visitAnnotation(annotation);
  //
  //       verifyNoReports(mockRule);
  //     },
  //   );
  //
  //   test('Reports when static fromJson method takes in no params', () async {
  //     final resolved = await dartResolver.resolveSource('''
  //       typedef Self = MyModel;
  //
  //       @GenerateJsonParser()
  //       class MyModel {
  //         static Self fromJson() => MyModel();
  //         Map<String, dynamic> toJson() => {};
  //       }
  //       ''');
  //
  //     final annotation = resolved.findAnnotation(
  //       annotationName: 'GenerateJsonParser',
  //     );
  //     if (annotation == null) {
  //       fail('Expected annotation to be found');
  //     }
  //
  //     sut.visitAnnotation(annotation);
  //
  //     verify(
  //       () => mockRule.reportAtNode(
  //         any(),
  //         arguments: [
  //           'fromJson method must have only one parameter of type Map<String, dynamic> or Map<String, Object?>.',
  //         ],
  //       ),
  //     ).called(1);
  //   });
  //
  //   test(
  //     'Reports when static fromJson method takes in more than one params',
  //     () async {
  //       final resolved = await dartResolver.resolveSource('''
  //       typedef Self = MyModel;
  //
  //       @GenerateJsonParser()
  //       class MyModel {
  //         static Self fromJson(int i, String s) => MyModel();
  //         Map<String, dynamic> toJson() => {};
  //       }
  //       ''');
  //
  //       final annotation = resolved.findAnnotation(
  //         annotationName: 'GenerateJsonParser',
  //       );
  //       if (annotation == null) {
  //         fail('Expected annotation to be found');
  //       }
  //
  //       sut.visitAnnotation(annotation);
  //
  //       verify(
  //         () => mockRule.reportAtNode(
  //           any(),
  //           arguments: [
  //             'fromJson method must have only one parameter of type Map<String, dynamic> or Map<String, Object?>.',
  //           ],
  //         ),
  //       ).called(1);
  //     },
  //   );
  //
  //   test(
  //     'Reports when static fromJson method takes in wrong param type',
  //     () async {
  //       stubIsMapOf(false);
  //
  //       final resolved = await dartResolver.resolveSource('''
  //       typedef Self = MyModel;
  //
  //       @GenerateJsonParser()
  //       class MyModel {
  //         static Self fromJson(int i) => MyModel();
  //         Map<String, dynamic> toJson() => {};
  //       }
  //       ''');
  //
  //       final annotation = resolved.findAnnotation(
  //         annotationName: 'GenerateJsonParser',
  //       );
  //       if (annotation == null) {
  //         fail('Expected annotation to be found');
  //       }
  //
  //       sut.visitAnnotation(annotation);
  //
  //       verify(
  //         () => mockRule.reportAtNode(
  //           any(),
  //           arguments: [
  //             'fromJson method must have only one parameter of type Map<String, dynamic> or Map<String, Object?>.',
  //           ],
  //         ),
  //       ).called(1);
  //     },
  //   );
  // });
}

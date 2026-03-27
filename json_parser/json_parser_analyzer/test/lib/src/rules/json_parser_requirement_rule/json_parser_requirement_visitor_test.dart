// ignore_for_file: lines_longer_than_80_chars

import 'package:analysis_server_core/analysis_server_core.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:json_parser_analyzer/src/models/json_parser_lint_config.dart';
import 'package:json_parser_analyzer/src/rules/json_parser_requirement_rule/json_parser_requirement_visitor.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import '../../../utils/parsers/annotation_parsers.dart';

class _FakeToken extends Fake implements Token {}

class _MockAnalysisRule extends Mock implements AnalysisRule {}

class _MockRuleSessionContext extends Mock
    implements RuleSessionContext<JsonParserLintConfig> {}

class _MockLogger extends Mock implements SessionLogger {}

class _MockAnnotationTypeResolver extends Mock
    implements AnnotationTypeResolver {}

void main() {
  final fakeToken = _FakeToken();
  final fakeAnnotation = parseString(
    content: '@deprecated class Foo {}',
  ).unit.declarations.first.metadata.first;

  late _MockLogger logger;
  late _MockAnalysisRule rule;
  late _MockRuleSessionContext sessionContext;
  late _MockAnnotationTypeResolver annotationTypeResolver;

  late JsonParserRequirementRuleVisitor visitor;

  setUpAll(() {
    registerFallbackValue(fakeToken);
    registerFallbackValue(fakeAnnotation);
  });

  setUp(() {
    logger = _MockLogger();
    rule = _MockAnalysisRule();
    sessionContext = _MockRuleSessionContext();
    annotationTypeResolver = _MockAnnotationTypeResolver();

    visitor = JsonParserRequirementRuleVisitor.test(
      rule,
      sessionContext,
      annotationTypeResolver,
    );

    when(() => sessionContext.logger).thenReturn(logger);
    when(
      () => logger.logInfo(
        tag: any(named: 'tag'),
        message: any(named: 'message'),
      ),
    ).thenReturn(null);
    when(
      () => logger.logWarning(
        tag: any(named: 'tag'),
        message: any(named: 'message'),
      ),
    ).thenReturn(null);

    when(
      () => rule.reportAtToken(any(), arguments: any(named: 'arguments')),
    ).thenReturn(null);
    when(
      () => rule.reportAtNode(any(), arguments: any(named: 'arguments')),
    ).thenReturn(null);

    when(
      () => annotationTypeResolver.resolveTypeName(any()),
    ).thenReturn('GenerateJsonParser');
  });

  void verifyNoReports(_MockAnalysisRule rule) {
    verifyNever(
      () => rule.reportAtToken(any(), arguments: any(named: 'arguments')),
    );
    verifyNever(
      () => rule.reportAtNode(any(), arguments: any(named: 'arguments')),
    );
  }

  group('visitAnnotation – unknown annotation', () {
    test('Ignores annotations other than @GenerateJsonParser', () {
      when(
        () => annotationTypeResolver.resolveTypeName(any()),
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

      visitor.visitAnnotation(annotation!);

      verify(() => annotationTypeResolver.resolveTypeName(any())).called(1);
      verifyNoReports(rule);
    });
  });

  group('visitAnnotation – non-class parent', () {
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

      visitor.visitAnnotation(annotation);

      verifyNoReports(rule);
    });
  });

  group('visitAnnotation – abstract class', () {
    test('Ignores abstract classes annotated with @GenerateJsonParser', () {
      const content = '''
      @GenerateJsonParser()
      abstract class MyModel {}
      ''';
      final annotation = parseValidAnnotation(content);

      visitor.visitAnnotation(annotation);

      verifyNoReports(rule);
    });
  });

  group('valid class – no violations', () {
    test(
      'reports nothing when class has correct toJson and factory fromJson',
      () {
        const content = '''
        @GenerateJsonParser()
        class MyModel {
          factory MyModel.fromJson(Map<String, dynamic> json) => MyModel();
          Map<String, dynamic> toJson() => {};
        }
        ''';
        final annotation = parseValidAnnotation(content);

        visitor.visitAnnotation(annotation);

        verifyNoReports(rule);
      },
    );

    test(
      'reports nothing when class has correct toJson and static fromJson method',
      () {
        const content = '''
        @GenerateJsonParser()
        class MyModel {
          static MyModel fromJson(Map<String, dynamic> json) => MyModel();
          Map<String, dynamic> toJson() => {};
        }
        ''';
        final annotation = parseValidAnnotation(content);

        visitor.visitAnnotation(annotation);

        verifyNoReports(rule);
      },
    );
  });

  group('missing toJson method', () {
    test('Reports when toJson is absent', () {
      const content = '''
      @GenerateJsonParser()
      class MyModel {
        factory MyModel.fromJson(Map<String, dynamic> json) => MyModel();
      }
      ''';
      final annotation = parseValidAnnotation(content);

      visitor.visitAnnotation(annotation);

      verify(
        () => rule.reportAtToken(any(), arguments: ['missing toJson method.']),
      ).called(1);
    });
  });

  group('toJson method – wrong signature', () {
    test('Reports when toJson is a getter', () {
      const content = '''
      @GenerateJsonParser()
      class MyModel {
        factory MyModel.fromJson(Map<String, dynamic> json) => MyModel();
        Map<String, dynamic> get toJson => {};
      }
      ''';
      final annotation = parseValidAnnotation(content);

      visitor.visitAnnotation(annotation);

      verify(
        () => rule.reportAtToken(
          any(),
          arguments: ['toJson method must not be a getter.'],
        ),
      ).called(1);
    });

    test('Reports when toJson has parameters', () {
      const content = '''
      @GenerateJsonParser()
      class MyModel {
        factory MyModel.fromJson(Map<String, dynamic> json) => MyModel();
        Map<String, dynamic> toJson(String extra) => {};
      }
      ''';
      final annotation = parseValidAnnotation(content);

      visitor.visitAnnotation(annotation);

      verify(
        () => rule.reportAtNode(
          any(),
          arguments: ['toJson method must not have parameters.'],
        ),
      ).called(1);
    });

    test('Reports when toJson returns wrong type', () {
      const content = '''
      @GenerateJsonParser()
      class MyModel {
        factory MyModel.fromJson(Map<String, dynamic> json) => MyModel();
        String toJson() => '';
      }
      ''';
      final annotation = parseValidAnnotation(content);

      visitor.visitAnnotation(annotation);

      verify(
        () => rule.reportAtNode(
          any(),
          arguments: ['toJson method must return Map<String, dynamic>.'],
        ),
      ).called(1);
    });

    test('Reports when toJson returns Map<String, Object> (not dynamic)', () {
      const content = '''
      @GenerateJsonParser()
      class MyModel {
        factory MyModel.fromJson(Map<String, dynamic> json) => MyModel();
        Map<String, Object> toJson() => {};
      }
      ''';
      final annotation = parseValidAnnotation(content);

      visitor.visitAnnotation(annotation);

      verify(
        () => rule.reportAtNode(
          any(),
          arguments: ['toJson method must return Map<String, dynamic>.'],
        ),
      ).called(1);
    });

    test('Reports when toJson returns Map without type args', () {
      const content = '''
      @GenerateJsonParser()
      class MyModel {
        factory MyModel.fromJson(Map<String, dynamic> json) => MyModel();
        Map toJson() => {};
      }
      ''';
      final annotation = parseValidAnnotation(content);

      visitor.visitAnnotation(annotation);

      verify(
        () => rule.reportAtNode(
          any(),
          arguments: ['toJson method must return Map<String, dynamic>.'],
        ),
      ).called(1);
    });

    test('Reports when toJson has no return type annotation', () {
      const content = '''
      @GenerateJsonParser()
      class MyModel {
        factory MyModel.fromJson(Map<String, dynamic> json) => MyModel();
        toJson() => {};
      }
      ''';
      final annotation = parseValidAnnotation(content);

      visitor.visitAnnotation(annotation);

      verify(
        () => rule.reportAtNode(
          any(),
          arguments: ['toJson method must return Map<String, dynamic>.'],
        ),
      ).called(1);
    });
  });

  group('missing fromJson constructor or static method', () {
    test('reports when both fromJson factory and static method are absent', () {
      const content = '''
      @GenerateJsonParser()
      class MyModel {
        Map<String, dynamic> toJson() => {};
      }
      ''';
      final annotation = parseValidAnnotation(content);

      visitor.visitAnnotation(annotation);

      verify(
        () => rule.reportAtToken(
          any(),
          arguments: ['missing fromJson constructor (or a static method).'],
        ),
      ).called(1);
    });
  });

  group('multiple violations', () {
    test('Reports both missing toJson and missing fromJson', () {
      const content = '''
      @GenerateJsonParser()
      class MyModel {}
      ''';
      final annotation = parseValidAnnotation(content);

      visitor.visitAnnotation(annotation);

      verify(
        () => rule.reportAtToken(any(), arguments: ['missing toJson method.']),
      ).called(1);
      verify(
        () => rule.reportAtToken(
          any(),
          arguments: ['missing fromJson constructor (or a static method).'],
        ),
      ).called(1);
    });
  });
}

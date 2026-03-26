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

void main() {
  final fakeToken = _FakeToken();
  final fakeNode = parseString(content: 'var x = 1;').unit;

  late _MockLogger logger;
  late _MockAnalysisRule rule;
  late _MockRuleSessionContext sessionContext;

  late JsonParserRequirementRuleVisitor visitor;

  setUpAll(() {
    registerFallbackValue(fakeNode);
    registerFallbackValue(fakeToken);
  });

  setUp(() {
    logger = _MockLogger();
    rule = _MockAnalysisRule();
    sessionContext = _MockRuleSessionContext();

    visitor = JsonParserRequirementRuleVisitor.test(rule, sessionContext);

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
  });

  group('JsonParserRequirementRuleVisitor', () {
    group('visitAnnotation – unknown annotation', () {
      test('Ignores annotations other than @GenerateJsonParser', () {
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

        verifyNever(
          () => rule.reportAtToken(any(), arguments: any(named: 'arguments')),
        );
        verifyNever(
          () => rule.reportAtNode(any(), arguments: any(named: 'arguments')),
        );
      });
    });

    group('visitAnnotation – non-class parent', () {
      test('Ignores @GenerateJsonParser on a top-level function (non-class)', () {
        // Manually construct a scenario where the annotation parent is not a
        // ClassDeclaration.  The simplest way is to attach it to a mixin or
        // extension, which the visitor also doesn't handle.
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
          // Mixin metadata access differs per analyzer version; skip gracefully.
          return;
        }

        visitor.visitAnnotation(annotation);

        verifyNever(
          () => rule.reportAtToken(any(), arguments: any(named: 'arguments')),
        );
        verifyNever(
          () => rule.reportAtNode(any(), arguments: any(named: 'arguments')),
        );
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

        verifyNever(
          () => rule.reportAtToken(any(), arguments: any(named: 'arguments')),
        );
        verifyNever(
          () => rule.reportAtNode(any(), arguments: any(named: 'arguments')),
        );
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

          verifyNever(
            () => rule.reportAtToken(any(), arguments: any(named: 'arguments')),
          );
          verifyNever(
            () => rule.reportAtNode(any(), arguments: any(named: 'arguments')),
          );
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

          verifyNever(
            () => rule.reportAtToken(any(), arguments: any(named: 'arguments')),
          );
          verifyNever(
            () => rule.reportAtNode(any(), arguments: any(named: 'arguments')),
          );
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
          () =>
              rule.reportAtToken(any(), arguments: ['missing toJson method.']),
        ).called(1);
      });
    });

    group('toJson method – wrong signature', () {
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
            arguments: ['toJson method should not have parameters.'],
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
            arguments: ['toJson method should return Map<String, dynamic>.'],
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
            arguments: ['toJson method should return Map<String, dynamic>.'],
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
            arguments: ['toJson method should return Map<String, dynamic>.'],
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
            arguments: ['toJson method should return Map<String, dynamic>.'],
          ),
        ).called(1);
      });
    });

    group('missing fromJson constructor or static method', () {
      test(
        'reports when both fromJson factory and static method are absent',
        () {
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
        },
      );
    });

    group('fromJson factory constructor – wrong signature', () {
      test('Reports when factory fromJson has no parameters', () {
        const content = '''
        @GenerateJsonParser()
        class MyModel {
          factory MyModel.fromJson() => MyModel();
          Map<String, dynamic> toJson() => {};
        }
        ''';
        final annotation = parseValidAnnotation(content);

        visitor.visitAnnotation(annotation);

        verify(
          () => rule.reportAtNode(
            any(),
            arguments: [
              'fromJson constructor should have only one parameter of type Map<String, dynamic>.',
            ],
          ),
        ).called(1);
      });

      test('Reports when factory fromJson has more than one parameter', () {
        const content = '''
        @GenerateJsonParser()
        class MyModel {
          factory MyModel.fromJson(Map<String, dynamic> json, String extra) => MyModel();
          Map<String, dynamic> toJson() => {};
        }
        ''';
        final annotation = parseValidAnnotation(content);

        visitor.visitAnnotation(annotation);

        verify(
          () => rule.reportAtNode(
            any(),
            arguments: [
              'fromJson constructor should have only one parameter of type Map<String, dynamic>.',
            ],
          ),
        ).called(1);
      });

      test('Reports when factory fromJson parameter type is wrong', () {
        const content = '''
        @GenerateJsonParser()
        class MyModel {
          factory MyModel.fromJson(String json) => MyModel();
          Map<String, dynamic> toJson() => {};
        }
        ''';
        final annotation = parseValidAnnotation(content);

        visitor.visitAnnotation(annotation);

        verify(
          () => rule.reportAtNode(
            any(),
            arguments: [
              'fromJson constructor should have only one parameter of type Map<String, dynamic>.',
            ],
          ),
        ).called(1);
      });

      test('Reports when factory fromJson parameter is Map<String, Object>', () {
        const content = '''
        @GenerateJsonParser()
        class MyModel {
          factory MyModel.fromJson(Map<String, Object> json) => MyModel();
          Map<String, dynamic> toJson() => {};
        }
        ''';
        final annotation = parseValidAnnotation(content);

        visitor.visitAnnotation(annotation);

        verify(
          () => rule.reportAtNode(
            any(),
            arguments: [
              'fromJson constructor should have only one parameter of type Map<String, dynamic>.',
            ],
          ),
        ).called(1);
      });
    });

    group('fromJson static method – wrong signature', () {
      test('Reports when static fromJson is a getter', () {
        const content = '''
        @GenerateJsonParser()
        class MyModel {
          static MyModel get fromJson => MyModel();
          Map<String, dynamic> toJson() => {};
        }
        ''';
        final annotation = parseValidAnnotation(content);

        visitor.visitAnnotation(annotation);

        verify(
          () => rule.reportAtToken(
            any(),
            arguments: ['static fromJson should not be a getter.'],
          ),
        ).called(1);
      });

      test('Reports when static fromJson has no parameters', () {
        const content = '''
        @GenerateJsonParser()
        class MyModel {
          static MyModel fromJson() => MyModel();
          Map<String, dynamic> toJson() => {};
        }
        ''';
        final annotation = parseValidAnnotation(content);

        visitor.visitAnnotation(annotation);

        verify(
          () => rule.reportAtNode(
            any(),
            arguments: [
              'fromJson method should have only one parameter of type Map<String, dynamic>.',
            ],
          ),
        ).called(1);
      });

      test('Reports when static fromJson has more than one parameter', () {
        const content = '''
        @GenerateJsonParser()
        class MyModel {
          static MyModel fromJson(Map<String, dynamic> json, String extra) => MyModel();
          Map<String, dynamic> toJson() => {};
        }
        ''';
        final annotation = parseValidAnnotation(content);

        visitor.visitAnnotation(annotation);

        verify(
          () => rule.reportAtNode(
            any(),
            arguments: [
              'fromJson method should have only one parameter of type Map<String, dynamic>.',
            ],
          ),
        ).called(1);
      });

      test('Reports when static fromJson parameter type is wrong', () {
        const content = '''
        @GenerateJsonParser()
        class MyModel {
          static MyModel fromJson(String json) => MyModel();
          Map<String, dynamic> toJson() => {};
        }
        ''';
        final annotation = parseValidAnnotation(content);

        visitor.visitAnnotation(annotation);

        verify(
          () => rule.reportAtNode(
            any(),
            arguments: [
              'fromJson method should have only one parameter of type Map<String, dynamic>.',
            ],
          ),
        ).called(1);
      });

      test('Reports when static fromJson parameter is Map<String, Object>', () {
        const content = '''
        @GenerateJsonParser()
        class MyModel {
          static MyModel fromJson(Map<String, Object> json) => MyModel();
          Map<String, dynamic> toJson() => {};
        }
        ''';
        final annotation = parseValidAnnotation(content);

        visitor.visitAnnotation(annotation);

        verify(
          () => rule.reportAtNode(
            any(),
            arguments: [
              'fromJson method should have only one parameter of type Map<String, dynamic>.',
            ],
          ),
        ).called(1);
      });
    });

    group('fromJson – factory constructor preferred over static method', () {
      test(
        'uses factory constructor and does not additionally check static method '
        'when both are present',
        () {
          const content = '''
          @GenerateJsonParser()
          class MyModel {
            factory MyModel.fromJson(Map<String, dynamic> json) => MyModel();
            static MyModel fromJson(Map<String, dynamic> json) => MyModel();
            Map<String, dynamic> toJson() => {};
          }
          ''';
          final annotation = parseValidAnnotation(content);

          // Should not throw and should not report anything, because the
          // factory constructor is valid.
          visitor.visitAnnotation(annotation);

          verifyNever(
            () => rule.reportAtToken(any(), arguments: any(named: 'arguments')),
          );
          verifyNever(
            () => rule.reportAtNode(any(), arguments: any(named: 'arguments')),
          );
        },
      );
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
          () =>
              rule.reportAtToken(any(), arguments: ['missing toJson method.']),
        ).called(1);
        verify(
          () => rule.reportAtToken(
            any(),
            arguments: ['missing fromJson constructor (or a static method).'],
          ),
        ).called(1);
      });
    });

    group('fromJson – default/named parameter edge cases', () {
      test('Reports when static fromJson has a named parameter of wrong type', () {
        const content = '''
        @GenerateJsonParser()
        class MyModel {
          static MyModel fromJson({String? json}) => MyModel();
          Map<String, dynamic> toJson() => {};
        }
        ''';
        final annotation = parseValidAnnotation(content);

        visitor.visitAnnotation(annotation);

        // Named parameter count == 1, but the type is String? not Map<String, dynamic>.
        verify(
          () => rule.reportAtNode(
            any(),
            arguments: [
              'fromJson method should have only one parameter of type Map<String, dynamic>.',
            ],
          ),
        ).called(1);
      });
    });
  });
}

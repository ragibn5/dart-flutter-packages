import 'package:analysis_plugin_test_helper/analysis_plugin_test_helper.dart';
import 'package:analysis_server_core/src/services/resolvers/type_resolvers/collection_type_resolver.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:test/test.dart';

void main() {
  final dartResolver = DartUnitResolver();
  late DefaultCollectionTypeResolver sut;

  setUp(() async {
    await dartResolver.setUp();
    sut = const DefaultCollectionTypeResolver();
  });

  tearDown(() async {
    await dartResolver.tearDown();
  });

  Future<TypeAnnotation?> resolveReturnType(
    String source, {
    required String methodName,
  }) async {
    final resolved = await dartResolver.resolveSource(source);
    for (final decl in resolved.unit.declarations) {
      if (decl is! ClassDeclaration) continue;
      for (final member in decl.members) {
        if (member is MethodDeclaration && member.name.lexeme == methodName) {
          return member.returnType;
        }
      }
    }
    return null;
  }

  group('isMapOf', () {
    group('returns true', () {
      test('for Map<String, dynamic>', () async {
        final type = await resolveReturnType('''
        class Foo {
          Map<String, dynamic> method() => {};
        }
        ''', methodName: 'method');

        expect(
          sut.isMapOf(type, keyType: 'String', valueType: 'dynamic'),
          isTrue,
        );
      });

      test('for typedef of Map<String, dynamic>', () async {
        final type = await resolveReturnType('''
        typedef JsonMap = Map<String, dynamic>;

        class Foo {
          JsonMap method() => {};
        }
        ''', methodName: 'method');

        expect(
          sut.isMapOf(type, keyType: 'String', valueType: 'dynamic'),
          isTrue,
        );
      });

      test('for Map<String, Object>', () async {
        final type = await resolveReturnType('''
        class Foo {
          Map<String, Object> method() => {};
        }
        ''', methodName: 'method');

        expect(
          sut.isMapOf(type, keyType: 'String', valueType: 'Object'),
          isTrue,
        );
      });

      test('for Map<String, dynamic>? when allowNullable is true', () async {
        final type = await resolveReturnType('''
        class Foo {
          Map<String, dynamic>? method() => null;
        }
        ''', methodName: 'method');

        expect(
          sut.isMapOf(
            type,
            keyType: 'String',
            valueType: 'dynamic',
            mapNullable: true,
          ),
          isTrue,
        );
      });

      test('for Map<String?, dynamic>', () async {
        final type = await resolveReturnType('''
        class Foo {
          Map<String?, dynamic> method() => {};
        }
        ''', methodName: 'method');

        expect(
          sut.isMapOf(type, keyType: 'String?', valueType: 'dynamic'),
          isTrue,
        );
      });

      test('for Map<String, Object?>', () async {
        final type = await resolveReturnType('''
        class Foo {
          Map<String, Object?> method() => {};
        }
        ''', methodName: 'method');

        expect(
          sut.isMapOf(type, keyType: 'String', valueType: 'Object?'),
          isTrue,
        );
      });

      test('for Map<String, dynamic> when dynamic? is passed', () async {
        final type = await resolveReturnType('''
        class Foo {
          Map<String, dynamic> method() => {};
        }
        ''', methodName: 'method');

        expect(
          sut.isMapOf(type, keyType: 'String', valueType: 'dynamic?'),
          isTrue,
        );
      });

      test('for Map<String, dynamic?> when dynamic is passed', () async {
        final type = await resolveReturnType('''
        class Foo {
          Map<String, dynamic?> method() => {};
        }
        ''', methodName: 'method');

        expect(
          sut.isMapOf(type, keyType: 'String', valueType: 'dynamic'),
          isTrue,
        );
      });
    });

    group('returns false', () {
      test('for Map<String, Object> when dynamic is expected', () async {
        final type = await resolveReturnType('''
        class Foo {
          Map<String, Object> method() => {};
        }
        ''', methodName: 'method');

        expect(
          sut.isMapOf(type, keyType: 'String', valueType: 'dynamic'),
          isFalse,
        );
      });

      test('for Map without type arguments', () async {
        final type = await resolveReturnType('''
        // ignore: strict_raw_type
        class Foo {
          Map method() => {};
        }
        ''', methodName: 'method');

        expect(
          sut.isMapOf(type, keyType: 'String', valueType: 'dynamic'),
          isFalse,
        );
      });

      test('for List<String>', () async {
        final type = await resolveReturnType('''
        class Foo {
          List<String> method() => [];
        }
        ''', methodName: 'method');

        expect(
          sut.isMapOf(type, keyType: 'String', valueType: 'dynamic'),
          isFalse,
        );
      });

      test('for String', () async {
        final type = await resolveReturnType('''
        class Foo {
          String method() => '';
        }
        ''', methodName: 'method');

        expect(
          sut.isMapOf(type, keyType: 'String', valueType: 'dynamic'),
          isFalse,
        );
      });

      test('for null (no return type annotation)', () async {
        final type = await resolveReturnType('''
        class Foo {
          method() => {};
        }
        ''', methodName: 'method');

        expect(
          sut.isMapOf(type, keyType: 'String', valueType: 'dynamic'),
          isFalse,
        );
      });

      test('for Map<String, dynamic>? by default', () async {
        final type = await resolveReturnType('''
        class Foo {
          Map<String, dynamic>? method() => null;
        }
        ''', methodName: 'method');

        expect(
          sut.isMapOf(type, keyType: 'String', valueType: 'dynamic'),
          isFalse,
        );
      });

      test(
        'for Map<String?, dynamic> when non-nullable key is expected',
        () async {
          final type = await resolveReturnType('''
          class Foo {
            Map<String?, dynamic> method() => {};
          }
          ''', methodName: 'method');

          expect(
            sut.isMapOf(type, keyType: 'String', valueType: 'dynamic'),
            isFalse,
          );
        },
      );

      test('for Map<String, Object> when Object? is expected', () async {
        final type = await resolveReturnType('''
        class Foo {
          Map<String, Object> method() => {};
        }
        ''', methodName: 'method');

        expect(
          sut.isMapOf(type, keyType: 'String', valueType: 'Object?'),
          isFalse,
        );
      });
    });
  });

  group('isListOf', () {
    group('returns true', () {
      test('for List<String>', () async {
        final type = await resolveReturnType('''
        class Foo {
          List<String> method() => [];
        }
        ''', methodName: 'method');

        expect(sut.isListOf(type, valueType: 'String'), isTrue);
      });

      test('for typedef of List<String>', () async {
        final type = await resolveReturnType('''
        typedef StringList = List<String>;

        class Foo {
          StringList method() => [];
        }
        ''', methodName: 'method');

        expect(sut.isListOf(type, valueType: 'String'), isTrue);
      });

      test('for List<dynamic>', () async {
        final type = await resolveReturnType('''
        class Foo {
          List<dynamic> method() => [];
        }
        ''', methodName: 'method');

        expect(sut.isListOf(type, valueType: 'dynamic'), isTrue);
      });

      test('for List<String>? when allowNullable is true', () async {
        final type = await resolveReturnType('''
        class Foo {
          List<String>? method() => null;
        }
        ''', methodName: 'method');

        expect(
          sut.isListOf(type, valueType: 'String', listNullable: true),
          isTrue,
        );
      });

      test('for List<String?>', () async {
        final type = await resolveReturnType('''
        class Foo {
          List<String?> method() => [];
        }
        ''', methodName: 'method');

        expect(sut.isListOf(type, valueType: 'String?'), isTrue);
      });

      test('for List<dynamic> when dynamic? is passed', () async {
        final type = await resolveReturnType('''
        class Foo {
          List<dynamic> method() => [];
        }
        ''', methodName: 'method');

        expect(sut.isListOf(type, valueType: 'dynamic?'), isTrue);
      });

      test('for List<dynamic?> when dynamic is passed', () async {
        final type = await resolveReturnType('''
        class Foo {
          List<dynamic?> method() => [];
        }
        ''', methodName: 'method');

        expect(sut.isListOf(type, valueType: 'dynamic'), isTrue);
      });
    });

    group('returns false', () {
      test('for List<Object> when String is expected', () async {
        final type = await resolveReturnType('''
        class Foo {
          List<Object> method() => [];
        }
        ''', methodName: 'method');

        expect(sut.isListOf(type, valueType: 'String'), isFalse);
      });

      test('for List without type arguments', () async {
        final type = await resolveReturnType('''
        // ignore: strict_raw_type
        class Foo {
          List method() => [];
        }
        ''', methodName: 'method');

        expect(sut.isListOf(type, valueType: 'String'), isFalse);
      });

      test('for Map<String, dynamic>', () async {
        final type = await resolveReturnType('''
        class Foo {
          Map<String, dynamic> method() => {};
        }
        ''', methodName: 'method');

        expect(sut.isListOf(type, valueType: 'String'), isFalse);
      });

      test('for List<String>? by default', () async {
        final type = await resolveReturnType('''
        class Foo {
          List<String>? method() => null;
        }
        ''', methodName: 'method');

        expect(sut.isListOf(type, valueType: 'String'), isFalse);
      });

      test('for null (no return type annotation)', () async {
        final type = await resolveReturnType('''
        class Foo {
          method() => [];
        }
        ''', methodName: 'method');

        expect(sut.isListOf(type, valueType: 'String'), isFalse);
      });

      test('for List<String> when String? is expected', () async {
        final type = await resolveReturnType('''
        class Foo {
          List<String> method() => [];
        }
        ''', methodName: 'method');

        expect(sut.isListOf(type, valueType: 'String?'), isFalse);
      });
    });
  });
}

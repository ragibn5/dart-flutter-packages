# analysis_plugin_test_helper

Utilities to help write tests for the analyzer plugins.

## Installation

#### From pub.dev

Add this to your `pubspec.yaml`

```yaml
dependencies:
  analysis_plugin_test_helper: ^1.0.4
```

#### Or, From Git repo

```yaml
dependencies:
  analysis_plugin_test_helper:
    git:
      url: https://github.com/Ragibn5/dart-flutter-packages.git
      path: analysis_plugin_test_helper
      ref: analysis_plugin_test_helper-1.0.4
```

For more information, see the [package on pub.dev](https://pub.dev/packages/analysis_plugin_test_helper) or the [GitHub repository](https://github.com/Ragibn5/dart-flutter-packages/tree/main/analysis_plugin_test_helper).

## Getting Started

### DartUnitResolver

Parsing Dart source (with `parseString` function from the `analyzer` package) gives you an unresolved AST, where every node in it is still just syntax. Whatever it refers to — a type, a declaration, a constant value — is only named, not linked to the actual thing. Without resolution, the AST tells you what's written, not what it means or what it points to.

Analyzer plugins work on the *resolved* picture — every reference linked to what it actually points to. Getting a resolved unit for a test normally means running the source through the full analysis pipeline by hand:

- Create an `AnalysisContextCollection`
- Write the source to a temp file
- Resolve it and extract a `ResolvedUnitResult`
- Clean up the temp files afterward

Every test file ends up repeating this. `DartUnitResolver` collapses it into one call — pass `resolveSource()` a Dart code string and get a resolved unit back.

```dart
import 'package:analysis_plugin_test_helper/analysis_plugin_test_helper.dart';
import 'package:test/test.dart';

void main() {
  final resolver = DartUnitResolver();

  setUpAll(() async => resolver.setUp());
  tearDownAll(() async => resolver.tearDown());

  test('example', () async {
    final result = await resolver.resolveSource('''
      class MyAnnotation {
        const MyAnnotation();
      }

      @MyAnnotation()
      class Foo {
        void myMethod() {}
      }
    ''');

    expect(result.diagnostics, isEmpty);
    // result.unit is a fully resolved CompilationUnit
  });
}
```

> **Note:** The source must be **standalone** — every declaration it references (classes, annotations, imports) must be self-contained within the string, since there's no surrounding project context to resolve against.

`resolveSource()` doesn't throw or fail just because the source has errors — syntactically invalid or semantically incorrect code still comes back as a `ResolvedUnitResult`. If you need to confirm the source was actually valid, check `result.diagnostics` yourself. It only throws a `StateError` in the rarer case where the analyzer can't produce a `ResolvedUnitResult` at all.

Call `setUp()` once before your tests run and `tearDown()` once after. This only creates and cleans up the temp directory the source files are written to — each call to `resolveSource()` still spins up and disposes its own `AnalysisContextCollection`, so don't rely on any state carrying over between calls.

### Parsers

Once you have `result.unit` from `DartUnitResolver`, these functions let you locate specific AST nodes without writing your own visitor.

Each capability comes in two forms:

| Prefix  | Returns            | Behavior when not found             |
|---------|--------------------|-------------------------------------|
| `find*` | nullable value     | returns `null`                      |
| `get*`  | non-nullable value | fails the current test via `fail()` |

Use `find*` when you're asserting something is *absent*, and `get*` when you're asserting on something you expect to exist.

#### Annotations

```dart
Annotation? findAnnotation<D extends CompilationUnitMember>(
  CompilationUnit unit, {
  required String annotationName,
})
```

Matches on the annotation's *resolved* type — via `elementAnnotation.computeConstantValue().type.element.name` — not on its source text. Because of that, this only works on a resolved unit; against an unresolved one it always returns `null`. It also means the annotation doesn't have to spell the type out directly: `@MyAnnotation()`, a reference to a `const` variable of that type, and a call through a `typedef` alias of it all match `annotationName: 'MyAnnotation'`.

```dart
typedef MAN = MyAnnotation;

@MAN()
class Foo {}
```

```dart
final annotation = getAnnotation(result.unit, annotationName: 'MyAnnotation');
```

The search only checks metadata on the top-level declaration itself (`unit.declarations`) — annotations on members inside it, like a method or field, aren't inspected. By default it searches every top-level declaration kind (classes, top-level functions and getters, and so on); the type parameter `D` narrows that to one kind, e.g. `getAnnotation<ClassDeclaration>(...)`, when you need to be specific about where the annotation should live.

#### Methods

```dart
MethodDeclaration? findMethodDeclaration(CompilationUnit unit, String name)
```

Searches the members of classes, mixins, extensions, extension types, and enums for a method named `name`. Top-level functions aren't covered.

```dart
final method = getMethodDeclaration(result.unit, 'myMethod');
```

#### Constructors

```dart
ConstructorDeclaration? findConstructorDeclaration(CompilationUnit unit, String? name)
```

Searches the same declaration kinds as `findMethodDeclaration`. `name` is the constructor's own name only — `'named'`, not `'Foo.named'`. Pass `null` to find the unnamed (default) constructor.

This matches by name alone, so it finds factory constructors too — use `findFactoryConstructorDeclaration` below when you specifically need to assert that a constructor is (or isn't) a factory.

```dart
final defaultCtor = getConstructorDeclaration(result.unit, null);
final namedCtor = getConstructorDeclaration(result.unit, 'named');
```

#### Factory constructors

```dart
ConstructorDeclaration? findFactoryConstructorDeclaration(CompilationUnit unit, String? name)
```

Same lookup as `findConstructorDeclaration`, restricted to constructors declared with `factory`. `null` finds the default factory constructor.

```dart
final factoryCtor = getFactoryConstructorDeclaration(result.unit, 'create');
```

#### Import directives

```dart
ImportDirective? findImportDirective(CompilationUnit unit)
```

Returns the first import directive in the unit — there's no filtering by URI. Useful when a test source has a single import you want to assert on directly.

```dart
final importDirective = getImportDirective(result.unit);
```

### Putting it together

```dart
test('plugin flags classes annotated with @MyAnnotation', () async {
  final result = await resolver.resolveSource('''
    class MyAnnotation {
      const MyAnnotation();
    }

    @MyAnnotation()
    class Foo {
      void myMethod() {}
    }
  ''');

  final annotation = getAnnotation(result.unit, annotationName: 'MyAnnotation');
  final method = getMethodDeclaration(result.unit, 'myMethod');

  expect(annotation, isNotNull);
  expect(method.name.lexeme, 'myMethod');
});
```

This is the shape most plugin tests take: resolve a small standalone snippet, pull the nodes under test out with the parser helpers, then assert on them directly rather than walking the AST by hand.

import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:test/test.dart';

/// Returns the first [MethodDeclaration] whose name matches [name],
/// or `null` if none is found.
///
/// Searches the members of all supported declaration kinds in [unit]:
/// - [ClassDeclaration]
/// - [MixinDeclaration]
/// - [ExtensionDeclaration]
/// - [ExtensionTypeDeclaration]
/// - [EnumDeclaration]
///
/// Unsupported kinds (e.g. [FunctionDeclaration],
/// [TopLevelVariableDeclaration], [TypeAlias]) are skipped.
MethodDeclaration? findMethodDeclaration(CompilationUnit unit, String name) {
  for (final declaration in unit.declarations) {
    final members = switch (declaration) {
      ClassDeclaration d => d.members,
      MixinDeclaration d => d.members,
      ExtensionDeclaration d => d.members,
      ExtensionTypeDeclaration d => d.members,
      EnumDeclaration d => d.members,
      _ => null,
    };
    final method = members
        ?.whereType<MethodDeclaration>()
        .where((m) => m.name.lexeme == name)
        .firstOrNull;
    if (method != null) return method;
  }

  return null;
}

/// Returns the first [MethodDeclaration] whose name matches [name],
/// failing the test if absent.
///
/// Searches the members of all supported declaration kinds in [unit]:
/// - [ClassDeclaration]
/// - [MixinDeclaration]
/// - [ExtensionDeclaration]
/// - [ExtensionTypeDeclaration]
/// - [EnumDeclaration]
///
/// Unsupported kinds (e.g. [FunctionDeclaration],
/// [TopLevelVariableDeclaration], [TypeAlias]) are skipped.
MethodDeclaration getMethodDeclaration(CompilationUnit unit, String name) {
  final method = findMethodDeclaration(unit, name);
  if (method == null) {
    fail('Could not find method "$name"');
  }

  return method;
}

/// Parses [content] and returns the first [MethodDeclaration] whose name
/// matches [name], or `null` if none is found.
///
/// Searches the members of the first declaration node found in the parsed
/// unit, regardless of its kind (class, mixin, extension, etc.).
///
/// The returned [MethodDeclaration] is **unresolved** — the AST is parsed
/// syntactically only. Properties that require resolution, such as
/// [Element] references and constant values, will be `null`. Use
/// [DartUnitResolver] if resolved information is needed.
MethodDeclaration? findParsedMethodDeclaration(String content, String name) {
  final unit = parseString(content: content).unit;
  return findMethodDeclaration(unit, name);
}

/// Parses [content] and returns the first [MethodDeclaration] whose name
/// matches [name], failing the test if absent.
///
/// Searches the members of the first declaration node found in the parsed
/// unit, regardless of its kind (class, mixin, extension, etc.).
///
/// The returned [MethodDeclaration] is **unresolved** —
/// see [findParsedMethodDeclaration] for details.
MethodDeclaration getParsedMethodDeclaration(String content, String name) {
  final method = findParsedMethodDeclaration(content, name);
  if (method == null) {
    fail('Could not find method "$name"');
  }

  return method;
}

import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:test/test.dart';

/// Returns the first [MethodDeclaration] whose name matches [name],
/// or `null` if none is found.
///
/// Searches the members of the first declaration node found in [unit].
/// Supported declaration kinds are:
/// - [ClassDeclaration]
/// - [MixinDeclaration]
/// - [ExtensionDeclaration]
/// - [ExtensionTypeDeclaration]
/// - [EnumDeclaration]
///
/// Throws an [UnsupportedError] if the first declaration is of an
/// unsupported kind (e.g. [FunctionDeclaration],
/// [TopLevelVariableDeclaration], [TypeAlias]).
MethodDeclaration? findMethodDeclaration(CompilationUnit unit, String name) {
  final declaration = unit.declarations.firstOrNull;
  if (declaration == null) return null;
  final members = switch (declaration) {
    ClassDeclaration d => d.members,
    MixinDeclaration d => d.members,
    ExtensionDeclaration d => d.members,
    ExtensionTypeDeclaration d => d.members,
    EnumDeclaration d => d.members,
    _ => throw UnsupportedError(
      'findMethodDeclaration does not support ${declaration.runtimeType}',
    ),
  };
  return members
      .whereType<MethodDeclaration>()
      .where((m) => m.name.lexeme == name)
      .firstOrNull;
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

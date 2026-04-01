import 'package:analyzer/dart/ast/ast.dart';
import 'package:test/test.dart';

/// Returns the first [MethodDeclaration] whose name matches [name],
/// or `null` if none is found.
///
/// Note:
/// - Searches the members of all supported declaration kinds:
///   - [ClassDeclaration]
///   - [MixinDeclaration]
///   - [ExtensionDeclaration]
///   - [ExtensionTypeDeclaration]
///   - [EnumDeclaration]
/// - Unsupported kinds (e.g. [FunctionDeclaration],
///   [TopLevelVariableDeclaration], [TypeAlias]) are skipped.
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
/// Note:
/// - Searches the members of all supported declaration kinds:
///   - [ClassDeclaration]
///   - [MixinDeclaration]
///   - [ExtensionDeclaration]
///   - [ExtensionTypeDeclaration]
///   - [EnumDeclaration]
/// - Unsupported kinds (e.g. [FunctionDeclaration],
///   [TopLevelVariableDeclaration], [TypeAlias]) are skipped.
MethodDeclaration getMethodDeclaration(CompilationUnit unit, String name) {
  final method = findMethodDeclaration(unit, name);
  if (method == null) {
    fail('Could not find method "$name"');
  }

  return method;
}

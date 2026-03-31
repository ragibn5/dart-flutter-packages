import 'package:analyzer/dart/ast/ast.dart';
import 'package:test/test.dart';

/// Returns the first [ConstructorDeclaration] whose name matches [name]
/// in [unit], or `null` if none is found. Pass `null` for [name] to find
/// the default constructor.
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
ConstructorDeclaration? findConstructorDeclaration(
  CompilationUnit unit,
  String? name,
) {
  for (final declaration in unit.declarations) {
    final members = switch (declaration) {
      ClassDeclaration d => d.members,
      MixinDeclaration d => d.members,
      ExtensionDeclaration d => d.members,
      ExtensionTypeDeclaration d => d.members,
      EnumDeclaration d => d.members,
      _ => null,
    };
    final constructor = members
        ?.whereType<ConstructorDeclaration>()
        .where((c) => c.name?.lexeme == name)
        .firstOrNull;
    if (constructor != null) return constructor;
  }

  return null;
}

/// Returns the first [ConstructorDeclaration] whose name matches [name]
/// in [unit], failing the test if absent. Pass `null` for [name] to find
/// the default constructor.
///
/// Searches the members of all supported declaration kinds —
/// see [findConstructorDeclaration] for details.
ConstructorDeclaration getConstructorDeclaration(
  CompilationUnit unit,
  String? name,
) {
  final constructor = findConstructorDeclaration(unit, name);
  if (constructor == null) {
    fail('Could not find constructor "${name ?? 'default'}"');
  }

  return constructor;
}

/// Returns the first factory [ConstructorDeclaration] whose name matches
/// [name] in [unit], or `null` if none is found. Pass `null` for [name]
/// to find the default factory constructor.
///
/// Searches the members of all supported declaration kinds —
/// see [findConstructorDeclaration] for details.
ConstructorDeclaration? findFactoryConstructorDeclaration(
  CompilationUnit unit,
  String? name,
) {
  for (final declaration in unit.declarations) {
    final members = switch (declaration) {
      ClassDeclaration d => d.members,
      MixinDeclaration d => d.members,
      ExtensionDeclaration d => d.members,
      ExtensionTypeDeclaration d => d.members,
      EnumDeclaration d => d.members,
      _ => null,
    };
    final constructor = members
        ?.whereType<ConstructorDeclaration>()
        .where((c) => c.name?.lexeme == name && c.factoryKeyword != null)
        .firstOrNull;
    if (constructor != null) return constructor;
  }

  return null;
}

/// Returns the first factory [ConstructorDeclaration] whose name matches
/// [name] in [unit], failing the test if absent. Pass `null` for [name]
/// to find the default factory constructor.
///
/// Searches the members of all supported declaration kinds —
/// see [findConstructorDeclaration] for details.
ConstructorDeclaration getFactoryConstructorDeclaration(
  CompilationUnit unit,
  String? name,
) {
  final constructor = findFactoryConstructorDeclaration(unit, name);
  if (constructor == null) {
    fail('Could not find factory constructor "${name ?? 'default'}"');
  }

  return constructor;
}

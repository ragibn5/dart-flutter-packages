import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:test/test.dart';

/// Returns the first [ConstructorDeclaration] whose name matches [name],
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

/// Returns the first [ConstructorDeclaration] whose name matches [name],
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
/// [name], or `null` if none is found.
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
/// [name], failing the test if absent.
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

/// Parses [content] and returns the first [ConstructorDeclaration] whose
/// name matches [name], or `null` if none is found.
///
/// The returned [ConstructorDeclaration] is **unresolved** — the AST is
/// parsed syntactically only. Properties that require resolution, such as
/// [Element] references and constant values, will be `null`. Use
/// [DartUnitResolver] if resolved information is needed.
ConstructorDeclaration? findParsedConstructorDeclaration(
  String content,
  String? name,
) {
  final unit = parseString(content: content).unit;
  return findConstructorDeclaration(unit, name);
}

/// Parses [content] and returns the first factory [ConstructorDeclaration]
/// whose name matches [name], or `null` if none is found.
///
/// The returned [ConstructorDeclaration] is **unresolved** — the AST is
/// parsed syntactically only. Properties that require resolution, such as
/// [Element] references and constant values, will be `null`. Use
/// [DartUnitResolver] if resolved information is needed.
ConstructorDeclaration? findParsedFactoryConstructorDeclaration(
  String content,
  String? name,
) {
  final unit = parseString(content: content).unit;
  return findFactoryConstructorDeclaration(unit, name);
}

/// Parses [content] and returns the first [ConstructorDeclaration] whose
/// name matches [name], failing the test if absent.
///
/// The returned [ConstructorDeclaration] is **unresolved** —
/// see [findParsedConstructorDeclaration] for details.
ConstructorDeclaration getParsedConstructorDeclaration(
  String content,
  String? name,
) {
  final constructor = findParsedConstructorDeclaration(content, name);
  if (constructor == null) {
    fail('Could not find constructor "${name ?? 'default'}"');
  }

  return constructor;
}

/// Parses [content] and returns the first factory [ConstructorDeclaration]
/// whose name matches [name], failing the test if absent.
///
/// The returned [ConstructorDeclaration] is **unresolved** —
/// see [findParsedFactoryConstructorDeclaration] for details.
ConstructorDeclaration getParsedFactoryConstructorDeclaration(
  String content,
  String? name,
) {
  final constructor = findParsedFactoryConstructorDeclaration(content, name);
  if (constructor == null) {
    fail('Could not find factory constructor "${name ?? 'default'}"');
  }

  return constructor;
}

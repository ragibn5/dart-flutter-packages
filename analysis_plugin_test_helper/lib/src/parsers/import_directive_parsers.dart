import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:test/expect.dart';

/// Returns the first [ImportDirective], or `null` if none is found.
ImportDirective? findImportDirective(CompilationUnit unit) {
  return unit.directives.whereType<ImportDirective>().firstOrNull;
}

/// Parses [content] and returns the first [ImportDirective], or `null`
/// if none is found.
///
/// The returned [ImportDirective] is **unresolved** — the AST is parsed
/// syntactically only. Properties that require resolution, will be `null`.
/// Use [DartUnitResolver] if resolved information is needed.
ImportDirective? findParsedImportDirective(String content) {
  return findImportDirective(parseString(content: content).unit);
}

/// Parses [content] and returns the import directive, failing the test if
/// absent.
///
/// The returned [ImportDirective] is **unresolved** — see
/// [findParsedImportDirective] for details.
ImportDirective getParsedImportDirective(String content) {
  final importDirective = findParsedImportDirective(content);
  if (importDirective == null) {
    fail('Could not find any import directive definition');
  }

  return importDirective;
}

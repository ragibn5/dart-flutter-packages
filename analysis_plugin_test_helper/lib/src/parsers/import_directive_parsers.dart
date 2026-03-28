import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:test/expect.dart';

/// Parses [content] and returns the first [ImportDirective], or `null`
/// if none is found.
///
/// The returned [ImportDirective] is **unresolved** — the AST is parsed
/// syntactically only. Properties that require resolution, will be `null`.
/// Use [DartUnitResolver] if resolved information is needed.
ImportDirective? parseImportDirective(String content) {
  return parseString(
    content: content,
  ).unit.directives.whereType<ImportDirective>().firstOrNull;
}

/// Parses [content] and returns the import directive, failing the test if
/// absent.
///
/// The returned [ImportDirective] is **unresolved** — see
/// [parseImportDirective] for details.
ImportDirective parseValidImportDirective(String content) {
  final importDirective = parseImportDirective(content);
  if (importDirective == null) {
    fail('Expected valid import directive definition, got: |$content|');
  }

  return importDirective;
}

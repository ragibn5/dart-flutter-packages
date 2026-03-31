import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:test/expect.dart';

/// Returns the first [ImportDirective], or `null` if none is found.
ImportDirective? findImportDirective(CompilationUnit unit) {
  return unit.directives.whereType<ImportDirective>().firstOrNull;
}

/// Returns the first [ImportDirective], failing the test if absent.
ImportDirective getImportDirective(CompilationUnit unit) {
  final importDirective = findImportDirective(unit);
  if (importDirective == null) {
    fail('Could not find any import directive definition');
  }

  return importDirective;
}

/// Parses [content] and returns the first [ImportDirective], or `null`
/// if none is found.
ImportDirective? findParsedImportDirective(String content) {
  return findImportDirective(parseString(content: content).unit);
}

/// Parses [content] and returns the import directive, failing the test if
/// absent.
ImportDirective getParsedImportDirective(String content) {
  final importDirective = findParsedImportDirective(content);
  if (importDirective == null) {
    fail('Could not find any import directive definition');
  }

  return importDirective;
}

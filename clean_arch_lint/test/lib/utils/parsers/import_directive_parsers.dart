import 'package:analysis_server_core/analysis_server_core.dart';
import 'package:test/expect.dart';

/// Parses [content] and returns the first [ImportDirective], or `null`
/// if none is found.
ImportDirective? parseImportDirective(String content) {
  return parseString(
    content: content,
  ).unit.directives.whereType<ImportDirective>().firstOrNull;
}

/// Parses [content] and returns the import directive, failing the test if
/// absent.
ImportDirective parseValidImportDirective(String content) {
  final importDirective = parseImportDirective(content);
  if (importDirective == null) {
    fail('Expected valid import directive definition, got: |$content|');
  }

  return importDirective;
}

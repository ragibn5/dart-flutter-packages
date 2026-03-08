import 'package:analysis_server_core/analysis_server_core.dart';
import 'package:test/expect.dart';

ImportDirective? parseImportDirective(String content) {
  return parseString(
    content: content,
  ).unit.directives.whereType<ImportDirective>().firstOrNull;
}

ImportDirective parseValidImportDirective(String content) {
  final importDirective = parseImportDirective(content);
  if (importDirective == null) {
    fail('Expected valid import directive definition, got: |$content|');
  }

  return importDirective;
}

import 'package:analysis_server_plugin_core/analysis_server_plugin_core.dart';
import 'package:clean_arch_lint/src/models/import_uri.dart';
import 'package:extended_string/extended_string.dart';

class ImportUriBuilder {
  ImportUri? fromImportNode(ImportDirective node) {
    final uriString = node.uri.stringValue?.trim().nullOnEmptyOrBlank;

    // Case 1: empty/null (after trimming)
    if (uriString == null) {
      return null;
    }
    // Case 2: no colon
    if (!uriString.contains(':')) {
      return ImportUri(path: uriString);
    }

    // Case 3: colon exists, parse x:y/z or x:y
    final match = RegExp(r'^([^:]*):([^/]+)(?:/(.*))?$').firstMatch(uriString);
    if (match == null) {
      return null;
    }

    final scheme = match.group(1)?.trim().nullOnEmptyOrBlank;
    final y = match.group(2)!; // packageName or path
    final z = match.group(3)?.trim().nullOnEmptyOrBlank;

    String? packageName;
    String path;
    if (z == null) {
      // No '/' part, y is considered the path
      packageName = null;
      path = y;
    } else {
      packageName = y;
      path = z;
    }

    return ImportUri(scheme: scheme, packageName: packageName, path: path);
  }
}

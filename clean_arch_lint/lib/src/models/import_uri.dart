import 'package:analysis_server_core/analysis_server_core.dart';
import 'package:clean_arch_lint/src/models/pair.dart';

class ImportUri {
  final String? scheme;
  final String? packageName;
  final String path;

  ImportUri({this.scheme, this.packageName, required this.path});

  @override
  String toString() {
    return '${scheme != null ? '$scheme:' : ''}'
        '${packageName != null ? '$packageName/' : ''}'
        '$path';
  }

  static ImportUri? fromImportNode(ImportDirective node) {
    final uriString = node.uri.stringValue;
    if (uriString == null) {
      return null;
    }

    String? scheme;
    String? packageName;
    String path;
    final colonSeparatedParts = uriString.split(':');
    if (colonSeparatedParts.length == 1) {
      path = uriString;
    } else {
      scheme = colonSeparatedParts[0];
      final namePathPair = _getPackageNameAndPathPair(colonSeparatedParts[1]);
      packageName = namePathPair.first;
      path = namePathPair.second;
    }

    return ImportUri(scheme: scheme, packageName: packageName, path: path);
  }

  static Pair<String?, String> _getPackageNameAndPathPair(
    String packageNameAndPath,
  ) {
    final slashSeparatedParts = packageNameAndPath.split('/');
    if (slashSeparatedParts.length > 1) {
      return Pair(
        slashSeparatedParts[0],
        slashSeparatedParts.sublist(1).join('/'),
      );
    } else {
      return Pair(null, packageNameAndPath);
    }
  }
}

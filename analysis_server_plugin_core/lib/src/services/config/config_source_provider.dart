import 'dart:io';

import 'package:analyzer/workspace/workspace.dart';
import 'package:path/path.dart' as path;

abstract interface class ConfigSourceProvider {
  File getConfigSource(WorkspacePackage package, String configFilePath);
}

class ConfigSourceProviderImpl implements ConfigSourceProvider {
  @override
  File getConfigSource(WorkspacePackage package, String configFilePath) {
    return File(path.join(package.root.path, configFilePath));
  }
}

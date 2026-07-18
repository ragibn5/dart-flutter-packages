import 'dart:io';

import 'package:analysis_server_plugin_core/analysis_server_plugin_core.dart';
import 'package:path/path.dart' as path;

abstract interface class ConfigSourceProvider {
  File getConfigSource(PackageInfo package, String configFilePath);
}

class ConfigSourceProviderImpl implements ConfigSourceProvider {
  @override
  File getConfigSource(PackageInfo package, String configFilePath) {
    return File(path.join(package.location, configFilePath));
  }
}

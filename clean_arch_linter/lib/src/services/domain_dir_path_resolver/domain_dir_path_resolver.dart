import 'package:analysis_server_plugin_core/analysis_server_plugin_core.dart';

class DomainDirPathResolver {
  /// Finds the domain directory path within [hostUnitPath].
  ///
  /// Returns the package-root-relative path of the domain directory,
  /// or `null` if the file is not inside any domain directory.
  ///
  /// e.g. `lib/feature/auth/domain/services/auth_service.dart`
  ///   → `lib/feature/auth/domain/`
  String? findDomainDirPath(String hostUnitPath, List<String> domainDirNames) {
    for (final name in domainDirNames) {
      final segment = name.surroundingPathSeparator(pathSeparator: '/');
      final idx = hostUnitPath.lastIndexOf(segment);
      if (idx != -1) {
        return hostUnitPath.substring(0, idx + segment.length);
      }
    }
    return null;
  }
}

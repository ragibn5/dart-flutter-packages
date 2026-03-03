import 'package:analysis_server_core/src/models/mappable.dart';

class SessionDataFactoryConfig implements Mappable {
  final String logDirectoryRelativePathFromProjectRoot;

  const SessionDataFactoryConfig({
    required this.logDirectoryRelativePathFromProjectRoot,
  });

  @override
  Map<String, dynamic> toMap() => {
    'logDirectoryRelativePathFromProjectRoot':
        logDirectoryRelativePathFromProjectRoot,
  };
}

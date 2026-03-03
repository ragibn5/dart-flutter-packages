import 'package:analysis_server_core/src/models/mappable.dart';

class ScanConfig implements Mappable {
  /// Whether to scan the `lib/` directory.
  final bool scanLibDir;

  /// Whether to scan the `test/` directory.
  final bool scanTestDir;

  const ScanConfig({this.scanLibDir = true, this.scanTestDir = false});

  @override
  Map<String, dynamic> toMap() => {
    'scanLibDir': scanLibDir,
    'scanTestDir': scanTestDir,
  };
}

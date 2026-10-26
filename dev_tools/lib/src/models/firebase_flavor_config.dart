import 'package:meta/meta.dart';

@immutable
class FirebaseFlavorConfig {
  final String projectId;
  final String iosBundleId;
  final String androidPackageName;

  const FirebaseFlavorConfig({
    required this.projectId,
    required this.iosBundleId,
    required this.androidPackageName,
  });

  @override
  bool operator ==(Object other) =>
      other is FirebaseFlavorConfig &&
      projectId == other.projectId &&
      iosBundleId == other.iosBundleId &&
      androidPackageName == other.androidPackageName;

  @override
  int get hashCode => Object.hash(projectId, iosBundleId, androidPackageName);
}

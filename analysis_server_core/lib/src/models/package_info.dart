import 'package:analysis_server_core/src/models/mappable.dart';

class PackageInfo implements Mappable {
  /// The name of the package being analyzed.
  ///
  /// - For standard dart packages, this is the `name`
  ///   field defined in the package's pubspec.yaml.
  /// - In case of non-package dart code, or standalone dart
  ///   files, this is **null**.
  final String? name;

  /// The absolute path of the package being analyzed.
  ///
  ///
  /// - For standard dart packages, this is the
  ///   root of the project.
  /// - In case of non-package dart code, or standalone dart
  ///   files, this is the parent of the file.
  final String location;

  PackageInfo({required this.name, required this.location});

  @override
  Map<String, dynamic> toMap() => {'name': name, 'location': location};
}

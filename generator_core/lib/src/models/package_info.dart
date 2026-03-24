import 'package:generator_core/src/models/mappable.dart';

class PackageInfo implements Mappable {
  /// The name of the package being analyzed.
  final String name;

  /// The absolute path of the package being analyzed.
  final String location;

  const PackageInfo({required this.name, required this.location});

  @override
  Map<String, dynamic> toMap() => {'name': name, 'location': location};
}

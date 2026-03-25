import 'package:generator_core/src/models/mappable.dart';

class PackageInfo implements Mappable {
  /// The name of the package being analyzed.
  final String name;

  const PackageInfo({required this.name});

  @override
  Map<String, dynamic> toMap() => {'name': name};
}

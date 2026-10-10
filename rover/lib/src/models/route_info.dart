import 'package:meta/meta.dart';

@immutable
class RouteInfo {
  final String name;
  final String path;

  const RouteInfo(this.name, this.path);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RouteInfo &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          path == other.path;

  @override
  int get hashCode => Object.hash(name, path);
}

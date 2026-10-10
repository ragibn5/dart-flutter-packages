import 'package:meta/meta.dart';

@immutable
class NavigationEvent {
  /// The name of the route that is being navigated to.
  ///
  /// Can be null if the route is an anonymous route.
  final String? toRoute;

  /// The name of the route that is being navigated from.
  ///
  /// Can be null if the route is an anonymous route.
  final String? fromRoute;

  const NavigationEvent({this.toRoute, this.fromRoute});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NavigationEvent &&
          runtimeType == other.runtimeType &&
          toRoute == other.toRoute &&
          fromRoute == other.fromRoute;

  @override
  int get hashCode => Object.hash(toRoute, fromRoute);
}

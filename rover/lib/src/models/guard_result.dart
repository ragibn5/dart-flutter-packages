import 'package:meta/meta.dart';
import 'package:rover/src/models/route_context.dart';

sealed class GuardResult {}

@immutable
final class ContinueNavigation extends GuardResult {
  final RouteContext current;
  final RouteContext next;

  ContinueNavigation({required this.current, required this.next});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ContinueNavigation &&
          runtimeType == other.runtimeType &&
          current == other.current &&
          next == other.next;

  @override
  int get hashCode => Object.hash(current, next);
}

@immutable
final class BlockNavigation extends GuardResult {
  final RouteContext current;
  final RouteContext blocked;

  BlockNavigation({required this.current, required this.blocked});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BlockNavigation &&
          runtimeType == other.runtimeType &&
          current == other.current &&
          blocked == other.blocked;

  @override
  int get hashCode => Object.hash(current, blocked);
}

@immutable
final class RedirectNavigation extends GuardResult {
  final RouteContext current;
  final RouteContext redirectRoute;

  RedirectNavigation({required this.current, required this.redirectRoute});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RedirectNavigation &&
          runtimeType == other.runtimeType &&
          current == other.current &&
          redirectRoute == other.redirectRoute;

  @override
  int get hashCode => Object.hash(current, redirectRoute);
}

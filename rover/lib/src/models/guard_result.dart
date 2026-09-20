import 'package:rover/src/models/route_context.dart';

sealed class GuardResult {}

final class ContinueNavigation extends GuardResult {
  final RouteContext current;
  final RouteContext next;

  ContinueNavigation({required this.current, required this.next});
}

final class BlockNavigation extends GuardResult {
  final RouteContext current;
  final RouteContext blocked;

  BlockNavigation({required this.current, required this.blocked});
}

final class RedirectNavigation extends GuardResult {
  final RouteContext current;
  final RouteContext redirectRoute;

  RedirectNavigation({required this.current, required this.redirectRoute});
}

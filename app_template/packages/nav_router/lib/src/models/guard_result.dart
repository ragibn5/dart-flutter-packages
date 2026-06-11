import 'package:nav_router/src/models/route_context.dart';

sealed class GuardResult {}

final class Continue extends GuardResult {}

final class Block extends GuardResult {}

final class Redirect extends GuardResult {
  final RouteContext redirectRoute;

  Redirect(this.redirectRoute);
}

import 'package:flutter/widgets.dart';
import 'package:nav_router/src/models/guard_result.dart';
import 'package:nav_router/src/models/route_context.dart';

abstract interface class RouteGuard {
  Future<GuardResult> onNavigationRequest(
    BuildContext context,
    RouteContext current,
    RouteContext next,
  );
}

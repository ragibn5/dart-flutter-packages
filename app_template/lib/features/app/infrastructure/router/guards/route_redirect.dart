import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Decides where a navigation goes instead, if anywhere.
abstract interface class RouteRedirect {
  /// Returns: the location to go to instead, or `null` to let the
  /// navigation through.
  Future<String?> call(BuildContext context, GoRouterState state);
}

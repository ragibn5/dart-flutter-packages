import 'package:flutter/widgets.dart';
import 'package:nav_router/src/models/route_context.dart';
import 'package:nav_router/src/nav_router.dart';

typedef RouteWidgetBuilder =
    Widget Function(
      BuildContext context,
      NavRouter router,
      RouteContext routeContext,
    );

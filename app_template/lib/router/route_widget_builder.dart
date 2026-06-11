import 'package:app_template/router/app_router.dart';
import 'package:app_template/router/route_context.dart';
import 'package:flutter/widgets.dart';

typedef RouteWidgetBuilder =
    Widget Function(
      BuildContext context,
      AppRouter router,
      RouteContext routeContext,
    );

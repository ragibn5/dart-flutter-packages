import 'package:app_logger/app_logger.dart';
import 'package:app_template/di/di.dart';
import 'package:app_template/features/app/presentation/widgets/root_redirection/root_redirection_page.dart';
import 'package:app_template/features/auth/domain/services/auth_data_service.dart';
import 'package:app_template/features/auth/presentation/bloc/login_bloc.dart';
import 'package:app_template/features/auth/presentation/screens/login_screen.dart';
import 'package:app_template/features/home/presentation/widgets/home_screen.dart';
import 'package:app_template/router/enums/app_routes.dart';
import 'package:app_template/router/guards/root_redirection_route_guard.dart';
import 'package:app_template/router/guards/router_logger.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  final AppLogger _logger;
  final AuthDataService _authDataService;

  AppRouter(
    GlobalKey<NavigatorState> rootNavigatorState,
    this._logger,
    this._authDataService,
  ) : super(navigatorKey: rootNavigatorState);

  @protected
  @override
  List<AutoRoute> get routes => [
    NamedRouteDef(
      initial: true,
      name: AppRoutes.ROOT.routeInfo.name,
      path: AppRoutes.ROOT.routeInfo.path,
      guards: [RootRedirectionRouteGuard(_authDataService)],
      builder: (c, d) => const RootRedirectionPage(),
    ),
    NamedRouteDef(
      name: AppRoutes.LOGIN.routeInfo.name,
      builder: (c, d) => BlocProvider(
        create: (context) => LoginBloc(di.get()),
        child: LoginScreen(
          onLoginComplete: () =>
              push(NamedRoute(AppRoutes.HOME.routeInfo.name)),
        ),
      ),
    ),
    NamedRouteDef(
      name: AppRoutes.HOME.routeInfo.name,
      builder: (c, d) => const HomeScreen(),
    ),
  ];

  @protected
  @override
  List<AutoRouteGuard> get guards => [RouterLogger(_logger)];
}

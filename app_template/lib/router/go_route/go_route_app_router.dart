import 'package:app_logger/app_logger.dart';
import 'package:app_template/di/di.dart';
import 'package:app_template/features/app/presentation/widgets/root_redirection/root_redirection_page.dart';
import 'package:app_template/features/auth/domain/services/auth_data_service.dart';
import 'package:app_template/features/auth/presentation/bloc/login_bloc.dart';
import 'package:app_template/features/auth/presentation/screens/login_screen.dart';
import 'package:app_template/features/home/presentation/widgets/home_screen.dart';
import 'package:app_template/router/app_router.dart';
import 'package:app_template/router/app_routes.dart';
import 'package:app_template/router/go_route/observers/router_logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class GoRouteAppRouter implements AppRouter {
  final GlobalKey<NavigatorState> _navigatorKey;

  final AppLogger _logger;
  final AuthDataService _authDataService;

  late final GoRouter _router = _buildRouter();

  GoRouteAppRouter({
    required GlobalKey<NavigatorState> navigatorKey,
    required AppLogger logger,
    required AuthDataService authDataService,
  }) : _navigatorKey = navigatorKey,
       _logger = logger,
       _authDataService = authDataService;

  @override
  RouterConfig<Object> get routerConfig => _router;

  @override
  Future<T?> pushWithName<T extends Object?>(String routeName) =>
      _router.pushNamed<T>(routeName);

  @override
  Future<T?> replaceWithName<T extends Object?>(String routeName) =>
      _router.replaceNamed<T>(routeName);

  @override
  void popTopRoute<T extends Object?>([T? result]) => _router.pop<T>(result);

  GoRouter _buildRouter() {
    return GoRouter(
      navigatorKey: _navigatorKey,
      initialLocation: AppRoutes.ROOT.routeInfo.path,
      redirect: buildRootRedirect,
      observers: [RouterLogger(_logger)],
      routes: [
        GoRoute(
          path: AppRoutes.ROOT.routeInfo.path,
          name: AppRoutes.ROOT.routeInfo.name,
          builder: (context, state) => const RootRedirectionPage(),
        ),
        GoRoute(
          path: AppRoutes.LOGIN.routeInfo.path,
          name: AppRoutes.LOGIN.routeInfo.name,
          builder: (context, state) => BlocProvider(
            create: (context) => LoginBloc(di.get()),
            child: LoginScreen(
              onLoginComplete: () =>
                  pushWithName(AppRoutes.HOME.routeInfo.name),
            ),
          ),
        ),
        GoRoute(
          path: AppRoutes.HOME.routeInfo.path,
          name: AppRoutes.HOME.routeInfo.name,
          builder: (context, state) => const HomeScreen(),
        ),
      ],
    );
  }

  Future<String?> buildRootRedirect(
    BuildContext context,
    GoRouterState state,
  ) async {
    final currentAuthData = await _authDataService.getCurrentAuthData();
    final isOnLogin = state.matchedLocation == AppRoutes.LOGIN.routeInfo.path;

    if (currentAuthData == null && !isOnLogin) {
      return AppRoutes.LOGIN.routeInfo.path;
    }
    if (currentAuthData != null && isOnLogin) {
      return AppRoutes.HOME.routeInfo.path;
    }

    return null;
  }
}

import 'package:app_template/features/app/infrastructure/enums/app_route.dart';
import 'package:app_template/features/app/infrastructure/router/guards/route_redirect.dart';
import 'package:app_template/features/app/presentation/widgets/root_redirection/root_redirection_page.dart';
import 'package:app_template/features/auth/application/use_cases/set_auth_data_use_case.dart';
import 'package:app_template/features/auth/presentation/bloc/login_bloc.dart';
import 'package:app_template/features/auth/presentation/widgets/login/login_page.dart';
import 'package:app_template/features/home/presentation/widgets/home_screen/home_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class RoutesProvider {
  // Guards
  final RouteRedirect _rootRedirect;

  // Use cases
  final SetAuthDataUseCase _setAuthDataUseCase;

  RoutesProvider(this._rootRedirect, this._setAuthDataUseCase);

  List<RouteBase> getAppRoutes() => [
    GoRoute(
      name: AppRoute.ROOT.routeName,
      path: AppRoute.ROOT.path,
      builder: (_, _) => const RootRedirectionPage(),
      redirect: _rootRedirect.call,
    ),
    GoRoute(
      name: AppRoute.LOGIN.routeName,
      path: AppRoute.LOGIN.path,
      builder: (context, _) => BlocProvider(
        create: (_) => LoginBloc(_setAuthDataUseCase),
        child: LoginPage(
          onLoginComplete: () => context.goNamed(AppRoute.HOME.routeName),
        ),
      ),
    ),
    GoRoute(
      name: AppRoute.HOME.routeName,
      path: AppRoute.HOME.path,
      builder: (_, _) => const HomePage(),
    ),
  ];
}

import 'package:app_template/di/di.dart';
import 'package:app_template/features/app/presentation/widgets/root_redirection/root_redirection_page.dart';
import 'package:app_template/features/auth/presentation/bloc/login_bloc.dart';
import 'package:app_template/features/auth/presentation/screens/login_screen.dart';
import 'package:app_template/features/home/presentation/widgets/home_screen.dart';
import 'package:app_template/router/app_router.dart';
import 'package:app_template/router/route_def.dart';
import 'package:app_template/router/route_info.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum AppRoutes {
  ROOT(RouteInfo('root', '/')),
  LOGIN(RouteInfo('login', '/login')),
  HOME(RouteInfo('home', '/home'));

  final RouteInfo routeInfo;

  const AppRoutes(this.routeInfo);
}

final appRouteDefs = [
  RouteDef(
    name: AppRoutes.ROOT.routeInfo.name,
    path: AppRoutes.ROOT.routeInfo.path,
    builder: (_, __) => const RootRedirectionPage(),
  ),
  RouteDef(
    name: AppRoutes.LOGIN.routeInfo.name,
    path: AppRoutes.LOGIN.routeInfo.path,
    builder: (_, __) => BlocProvider(
      create: (_) => LoginBloc(di.get()),
      child: LoginScreen(
        onLoginComplete: () =>
            di.get<AppRouter>().pushWithName(AppRoutes.HOME.routeInfo.name),
      ),
    ),
  ),
  RouteDef(
    name: AppRoutes.HOME.routeInfo.name,
    path: AppRoutes.HOME.routeInfo.path,
    builder: (_, __) => const HomeScreen(),
  ),
];

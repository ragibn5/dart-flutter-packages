// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:app_template/features/app/presentation/widgets/root_redirection_screen.dart'
    as _i3;
import 'package:app_template/features/auth/presentation/screens/login_screen.dart'
    as _i2;
import 'package:app_template/features/home/presentation/widgets/home_screen.dart'
    as _i1;
import 'package:auto_route/auto_route.dart' as _i4;

/// generated route for
/// [_i1.HomeScreen]
class HomeRoute extends _i4.PageRouteInfo<void> {
  const HomeRoute({List<_i4.PageRouteInfo>? children})
    : super(HomeRoute.name, initialChildren: children);

  static const String name = 'HomeRoute';

  static _i4.PageInfo page = _i4.PageInfo(
    name,
    builder: (data) {
      return const _i1.HomeScreen();
    },
  );
}

/// generated route for
/// [_i2.LoginScreen]
class LoginRoute extends _i4.PageRouteInfo<void> {
  const LoginRoute({List<_i4.PageRouteInfo>? children})
    : super(LoginRoute.name, initialChildren: children);

  static const String name = 'LoginRoute';

  static _i4.PageInfo page = _i4.PageInfo(
    name,
    builder: (data) {
      return _i4.WrappedRoute(child: const _i2.LoginScreen());
    },
  );
}

/// generated route for
/// [_i3.RootRedirectionScreen]
class RootRedirectionRoute extends _i4.PageRouteInfo<void> {
  const RootRedirectionRoute({List<_i4.PageRouteInfo>? children})
    : super(RootRedirectionRoute.name, initialChildren: children);

  static const String name = 'RootRedirectionRoute';

  static _i4.PageInfo page = _i4.PageInfo(
    name,
    builder: (data) {
      return const _i3.RootRedirectionScreen();
    },
  );
}

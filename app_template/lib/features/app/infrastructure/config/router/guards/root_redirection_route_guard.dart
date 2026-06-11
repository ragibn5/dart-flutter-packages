import 'package:app_template/features/app/infrastructure/enums/app_route.dart';
import 'package:app_template/features/auth/domain/services/auth_data_service.dart';
import 'package:auto_route/auto_route.dart';

class RootRedirectionRouteGuard extends AutoRouteGuard {
  final AuthDataService _authDataService;

  RootRedirectionRouteGuard(this._authDataService);

  @override
  Future<void> onNavigation(
    NavigationResolver resolver,
    StackRouter router,
  ) async {
    final currentAuthData = await _authDataService.getCurrentAuthData();
    if (currentAuthData == null) {
      await router.replace(NamedRoute(AppRoute.LOGIN.routeInfo.name));
    } else {
      await router.replace(NamedRoute(AppRoute.HOME.routeInfo.name));
    }

    resolver.next(false);
  }
}

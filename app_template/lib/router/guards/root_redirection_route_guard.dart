import 'package:app_template/features/auth/domain/services/auth_data_service.dart';
import 'package:app_template/router/app_router.gr.dart';
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
      await resolver.redirectUntil(const LoginRoute());
    } else {
      await resolver.redirectUntil(const HomeRoute());
    }

    resolver.next(false);
  }
}

import 'package:app_template/features/app/application/use_cases/is_authed_use_case.dart';
import 'package:app_template/features/app/infrastructure/config/router/routes_provider.dart';
import 'package:app_template/features/app/infrastructure/enums/app_route.dart';
import 'package:app_template/features/auth/application/use_cases/set_auth_data_use_case.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockIsAuthedUseCase extends Mock implements IsAuthedUseCase {}

class _MockSetAuthDataUseCase extends Mock implements SetAuthDataUseCase {}

void main() {
  late RoutesProvider sut;

  setUp(() {
    sut = RoutesProvider(_MockIsAuthedUseCase(), _MockSetAuthDataUseCase());
  });

  group('getAppRoutes', () {
    test('Should return all app routes', () {
      final routes = sut.getAppRoutes();

      expect(routes, hasLength(3));
      expect(
        routes.map((route) => route.info.name),
        containsAll([
          AppRoute.ROOT.routeInfo.name,
          AppRoute.LOGIN.routeInfo.name,
          AppRoute.HOME.routeInfo.name,
        ]),
      );
    });
  });
}

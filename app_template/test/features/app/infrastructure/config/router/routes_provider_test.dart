import 'package:app_template/features/app/infrastructure/config/router/routes_provider.dart';
import 'package:app_template/features/app/infrastructure/enums/app_route.dart';
import 'package:app_template/features/app/infrastructure/router/guards/route_redirect.dart';
import 'package:app_template/features/auth/application/use_cases/set_auth_data_use_case.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

class _MockRouteRedirect extends Mock implements RouteRedirect {}

class _MockSetAuthDataUseCase extends Mock implements SetAuthDataUseCase {}

void main() {
  late RoutesProvider sut;

  setUp(() {
    sut = RoutesProvider(_MockRouteRedirect(), _MockSetAuthDataUseCase());
  });

  test('getAppRoutesShouldReturnARouteForEveryAppRouteIfCalled', () {
    final names = sut.getAppRoutes().cast<GoRoute>().map((e) => e.name);

    expect(
      names,
      unorderedEquals([for (final route in AppRoute.values) route.routeName]),
    );
  });
}

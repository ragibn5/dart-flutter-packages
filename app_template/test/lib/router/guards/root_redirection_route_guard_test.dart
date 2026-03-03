// ignore_for_file: lines_longer_than_80_chars

import 'package:app_template/features/auth/domain/models/auth_data.dart';
import 'package:app_template/features/auth/domain/services/auth_data_service.dart';
import 'package:app_template/router/app_router.gr.dart';
import 'package:app_template/router/guards/root_redirection_route_guard.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockStackRouter extends Mock implements StackRouter {}

class _MockNavigationResolver extends Mock implements NavigationResolver {}

class _MockAuthDataService extends Mock implements AuthDataService {}

class _FakeAuthData extends Fake implements AuthData {}

void main() {
  const homeRoute = HomeRoute();
  const loginRoute = LoginRoute();
  final fakeAuthData = _FakeAuthData();

  late _MockStackRouter router;
  late _MockNavigationResolver resolver;
  late _MockAuthDataService authDataService;

  late RootRedirectionRouteGuard rootRedirectionRouteGuard;

  setUpAll(() {
    registerFallbackValue(homeRoute);
    registerFallbackValue(loginRoute);
    registerFallbackValue(_FakeAuthData());
  });

  setUp(() {
    router = _MockStackRouter();
    resolver = _MockNavigationResolver();
    authDataService = _MockAuthDataService();

    rootRedirectionRouteGuard = RootRedirectionRouteGuard(authDataService);

    when(() => resolver.next(any())).thenAnswer((_) {});
    when(() => resolver.redirectUntil(any())).thenAnswer((_) async => null);
  });

  test(
    'If not authenticated should redirect to login and abort navigation',
    () async {
      when(
        () => authDataService.getCurrentAuthData(),
      ).thenAnswer((_) async => null);

      await rootRedirectionRouteGuard.onNavigation(resolver, router);

      verify(() => resolver.redirectUntil(loginRoute)).called(1);
      verify(() => resolver.next(false)).called(1);
    },
  );

  test(
    'If authenticated should redirect to home and abort navigation',
    () async {
      when(
        () => authDataService.getCurrentAuthData(),
      ).thenAnswer((_) async => fakeAuthData);

      await rootRedirectionRouteGuard.onNavigation(resolver, router);

      verify(() => resolver.redirectUntil(homeRoute)).called(1);
      verify(() => resolver.next(false)).called(1);
    },
  );
}

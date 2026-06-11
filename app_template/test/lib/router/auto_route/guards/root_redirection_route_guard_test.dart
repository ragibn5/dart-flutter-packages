// ignore_for_file: lines_longer_than_80_chars

import 'package:app_template/features/auth/domain/models/auth_data.dart';
import 'package:app_template/features/auth/domain/services/auth_data_service.dart';
import 'package:app_template/router/app_route.dart';
import 'package:app_template/router/auto_route/guards/root_redirection_route_guard.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockStackRouter extends Mock implements StackRouter {}

class _MockNavigationResolver extends Mock implements NavigationResolver {}

class _MockAuthDataService extends Mock implements AuthDataService {}

class _FakeAuthData extends Fake implements AuthData {}

void main() {
  final fakeAuthData = _FakeAuthData();

  late _MockStackRouter mockRouter;
  late _MockNavigationResolver mockResolver;
  late _MockAuthDataService mockAuthDataService;

  late RootRedirectionRouteGuard sut;

  setUpAll(() {
    registerFallbackValue(NamedRoute(''));
    registerFallbackValue(_FakeAuthData());
  });

  setUp(() {
    mockRouter = _MockStackRouter();
    mockResolver = _MockNavigationResolver();
    mockAuthDataService = _MockAuthDataService();

    sut = RootRedirectionRouteGuard(mockAuthDataService);

    when(() => mockResolver.next(any())).thenAnswer((_) {});
    when(() => mockRouter.replace(any())).thenAnswer((_) async {});
  });

  test(
    'If not authenticated should redirect to login and abort navigation',
    () async {
      when(
        () => mockAuthDataService.getCurrentAuthData(),
      ).thenAnswer((_) async => null);

      await sut.onNavigation(mockResolver, mockRouter);

      verify(
        () => mockRouter.replace(NamedRoute(AppRoute.LOGIN.routeInfo.name)),
      ).called(1);
      verify(() => mockResolver.next(false)).called(1);
    },
  );

  test(
    'If authenticated should redirect to home and abort navigation',
    () async {
      when(
        () => mockAuthDataService.getCurrentAuthData(),
      ).thenAnswer((_) async => fakeAuthData);

      await sut.onNavigation(mockResolver, mockRouter);

      verify(
        () => mockRouter.replace(NamedRoute(AppRoute.HOME.routeInfo.name)),
      ).called(1);
      verify(() => mockResolver.next(false)).called(1);
    },
  );
}

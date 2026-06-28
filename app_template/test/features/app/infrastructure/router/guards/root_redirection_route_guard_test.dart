import 'package:app_template/features/app/infrastructure/enums/app_route.dart';
import 'package:app_template/features/app/infrastructure/router/guards/root_redirection_route_guard.dart';
import 'package:app_template/features/auth/domain/entities/auth_data.dart';
import 'package:app_template/features/auth/domain/services/auth_data_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nav_router/nav_router.dart';

class _MockAuthDataService extends Mock implements AuthDataService {}

class _FakeAuthData extends Fake implements AuthData {}

class _FakeBuildContext extends Fake implements BuildContext {}

void main() {
  final fakeAuthData = _FakeAuthData();

  late _MockAuthDataService mockAuthDataService;

  late RootRedirectRouteGuard sut;

  setUp(() {
    mockAuthDataService = _MockAuthDataService();
    sut = RootRedirectRouteGuard(mockAuthDataService);
  });

  test('If not authenticated should redirect to login', () async {
    when(
      () => mockAuthDataService.getCurrentAuthData(),
    ).thenAnswer((_) async => null);

    final result = await sut.onNavigationRequest(
      _FakeBuildContext(),
      RouteContext(info: AppRoute.HOME.routeInfo),
      RouteContext(info: AppRoute.LOGIN.routeInfo),
    );

    expect(result, isA<RedirectNavigation>());
    expect(
      (result as RedirectNavigation).redirectRoute.info.name,
      AppRoute.LOGIN.routeInfo.name,
    );
  });

  test('If authenticated should redirect to home', () async {
    when(
      () => mockAuthDataService.getCurrentAuthData(),
    ).thenAnswer((_) async => fakeAuthData);

    final result = await sut.onNavigationRequest(
      _FakeBuildContext(),
      RouteContext(info: AppRoute.LOGIN.routeInfo),
      RouteContext(info: AppRoute.HOME.routeInfo),
    );

    expect(result, isA<RedirectNavigation>());
    expect(
      (result as RedirectNavigation).redirectRoute.info.name,
      AppRoute.HOME.routeInfo.name,
    );
  });
}

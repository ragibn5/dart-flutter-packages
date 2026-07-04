import 'package:app_template/features/app/application/use_cases/get_auth_state_use_case.dart';
import 'package:app_template/features/app/infrastructure/enums/app_route.dart';
import 'package:app_template/features/app/infrastructure/router/guards/root_redirection_route_guard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nav_router/nav_router.dart';

class _MockGetAuthStateUseCase extends Mock implements GetAuthStateUseCase {}

class _FakeBuildContext extends Fake implements BuildContext {}

void main() {
  late _MockGetAuthStateUseCase mockGetAuthState;

  late RootRedirectRouteGuard sut;

  setUp(() {
    mockGetAuthState = _MockGetAuthStateUseCase();
    sut = RootRedirectRouteGuard(mockGetAuthState);
  });

  test('If not authenticated should redirect to login', () async {
    when(() => mockGetAuthState()).thenAnswer((_) async => true);

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
    when(() => mockGetAuthState()).thenAnswer((_) async => false);

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

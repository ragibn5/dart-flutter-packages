import 'package:app_template/features/app/application/use_cases/is_authed_use_case.dart';
import 'package:app_template/features/app/infrastructure/enums/app_route.dart';
import 'package:app_template/features/app/infrastructure/router/guards/root_redirection_route_guard.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

class _FakeBuildContext extends Fake implements BuildContext {}

class _MockGoRouterState extends Mock implements GoRouterState {}

class _MockIsAuthedUseCase extends Mock implements IsAuthedUseCase {}

void main() {
  final context = _FakeBuildContext();

  late _MockGoRouterState mockState;
  late _MockIsAuthedUseCase mockIsAuthed;

  late RootRedirectRouteGuard sut;

  setUp(() {
    mockState = _MockGoRouterState();
    mockIsAuthed = _MockIsAuthedUseCase();

    sut = RootRedirectRouteGuard(mockIsAuthed);

    for (final route in [AppRoute.HOME, AppRoute.LOGIN]) {
      when(
        () => mockState.namedLocation(route.routeName),
      ).thenReturn(route.path);
    }
  });

  test('callShouldReturnTheHomePageIfLoggedIn', () async {
    when(() => mockIsAuthed()).thenAnswer((_) async => true);

    expect(await sut(context, mockState), AppRoute.HOME.path);
  });

  test('callShouldReturnTheLoginPageIfNotLoggedIn', () async {
    when(() => mockIsAuthed()).thenAnswer((_) async => false);

    expect(await sut(context, mockState), AppRoute.LOGIN.path);
  });
}

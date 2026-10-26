import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rover/rover.dart';

class _MockRouteGuard extends Mock implements RouteGuard {}

class _MockBuildContext extends Mock implements BuildContext {}

void main() {
  setUpAll(() {
    registerFallbackValue(_MockBuildContext());
    registerFallbackValue(const RouteContext(info: RouteInfo('', '')));
  });

  group('RouteGuard', () {
    test('can be mocked and returns GuardResult', () async {
      final guard = _MockRouteGuard();
      when(() => guard.onNavigationRequest(any(), any(), any())).thenAnswer((
        invocation,
      ) async {
        return BlockNavigation(
          current: invocation.positionalArguments[1] as RouteContext,
          blocked: invocation.positionalArguments[2] as RouteContext,
        );
      });

      const info = RouteInfo('test', '/test');
      final result = await guard.onNavigationRequest(
        _MockBuildContext(),
        const RouteContext(info: info),
        const RouteContext(info: info),
      );
      expect(result, isA<BlockNavigation>());
    });

    test('can return Continue', () async {
      final guard = _MockRouteGuard();
      when(() => guard.onNavigationRequest(any(), any(), any())).thenAnswer((
        invocation,
      ) async {
        return ContinueNavigation(
          current: invocation.positionalArguments[1] as RouteContext,
          next: invocation.positionalArguments[2] as RouteContext,
        );
      });

      const info = RouteInfo('test', '/test');
      final result = await guard.onNavigationRequest(
        _MockBuildContext(),
        const RouteContext(info: info),
        const RouteContext(info: info),
      );
      expect(result, isA<ContinueNavigation>());
    });

    test('can return Redirect', () async {
      final guard = _MockRouteGuard();
      when(() => guard.onNavigationRequest(any(), any(), any())).thenAnswer(
        (invocation) async => RedirectNavigation(
          current: invocation.positionalArguments[1] as RouteContext,
          redirectRoute: const RouteContext(
            info: RouteInfo('redirect', '/redirect'),
          ),
        ),
      );

      const info = RouteInfo('test', '/test');
      final result = await guard.onNavigationRequest(
        _MockBuildContext(),
        const RouteContext(info: info),
        const RouteContext(info: info),
      );
      expect(result, isA<RedirectNavigation>());
      expect(
        (result as RedirectNavigation).redirectRoute.info.name,
        'redirect',
      );
    });
  });
}

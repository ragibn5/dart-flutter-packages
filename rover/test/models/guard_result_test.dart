import 'package:flutter_test/flutter_test.dart';
import 'package:rover/rover.dart';

void main() {
  group('GuardResult', () {
    const current = RouteContext(info: RouteInfo('current', '/current'));
    const next = RouteContext(info: RouteInfo('next', '/next'));

    test('Continue is a GuardResult', () {
      expect(
        ContinueNavigation(current: current, next: next),
        isA<GuardResult>(),
      );
    });

    test('Block is a GuardResult', () {
      expect(
        BlockNavigation(current: current, blocked: next),
        isA<GuardResult>(),
      );
    });

    test('Redirect is a GuardResult', () {
      const redirectRoute = RouteContext(info: RouteInfo('test', '/test'));
      final result = RedirectNavigation(
        current: current,
        redirectRoute: redirectRoute,
      );
      expect(result, isA<GuardResult>());
      expect(result.redirectRoute, same(redirectRoute));
    });
  });
}

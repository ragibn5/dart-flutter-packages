import 'package:app_template/features/app/infrastructure/router/guards/router_logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nav_router/nav_router.dart';

class _FakeBuildContext extends Fake implements BuildContext {}

void main() {
  test('Should return ContinueNavigation and not throw', () async {
    final sut = RouterLogger();
    final context = _FakeBuildContext();
    final current = RouteContext(info: const RouteInfo('current', '/current'));
    final next = RouteContext(info: const RouteInfo('next', '/next'));

    final result = await sut.onNavigationRequest(context, current, next);

    expect(result, isA<ContinueNavigation>());
  });
}

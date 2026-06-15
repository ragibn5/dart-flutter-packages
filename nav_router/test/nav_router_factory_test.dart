import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nav_router/nav_router.dart';

Widget _dummyBuilder(
  BuildContext context,
  NavRouter router,
  RouteContext routeContext,
) => const SizedBox.shrink();

void main() {
  group('NavRouterFactory', () {
    late NavRouterFactory sut;

    setUp(() {
      sut = NavRouterFactory();
    });

    test('create returns a NavRouter', () {
      final router = sut.create(
        navigatorKey: GlobalKey<NavigatorState>(),
        initialRoute: const RouteInfo('root', '/'),
        routes: [
          RouteDef(
            info: const RouteInfo('home', '/home'),
            builder: _dummyBuilder,
          ),
        ],
      );
      expect(router, isA<NavRouter>());
    });
  });
}

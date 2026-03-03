// ignore_for_file: lines_longer_than_80_chars

import 'package:app_template/router/guards/router_logger.dart';
import 'package:app_template/shared/logger/app_logger.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockStackRouter extends Mock implements StackRouter {}

class _MockNavigationResolver extends Mock implements NavigationResolver {}

class _MockAppLogger extends Mock implements AppLogger {}

class _MockRouteData extends Mock implements RouteData<dynamic> {}

void main() {
  const nextRouteName = 'route2';
  const currentRouteName = 'route1';
  final currentRouteData = _MockRouteData();

  late _MockAppLogger logger;
  late _MockStackRouter router;
  late _MockNavigationResolver resolver;

  late RouterLogger routerLogger;

  setUpAll(() {});

  setUp(() {
    logger = _MockAppLogger();
    router = _MockStackRouter();
    resolver = _MockNavigationResolver();

    routerLogger = RouterLogger(logger);

    when(() => router.current).thenAnswer((_) => currentRouteData);
    when(() => currentRouteData.name).thenAnswer((_) => currentRouteName);
    when(() => resolver.routeName).thenAnswer((_) => nextRouteName);
    when(() => resolver.next(any())).thenAnswer((_) {});
    when(
      () => logger.logDebug(
        tag: any(named: 'tag'),
        message: any(named: 'message'),
      ),
    ).thenAnswer((_) {});
  });

  test('Should log when any navigation event occurs and calls next', () async {
    routerLogger.onNavigation(resolver, router);

    verify(
      () => logger.logDebug(
        tag: RouterLogger.TAG,
        message: routerLogger.buildLogMessage(currentRouteName, nextRouteName),
      ),
    );
    verify(() => resolver.next()).called(1);
  });
}

// ignore_for_file: lines_longer_than_80_chars

import 'package:app_logger/app_logger.dart';
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

  late _MockAppLogger mockLogger;
  late _MockStackRouter mockRouter;
  late _MockNavigationResolver mockResolver;

  late RouterLogger sut;

  setUpAll(() {});

  setUp(() {
    mockLogger = _MockAppLogger();
    mockRouter = _MockStackRouter();
    mockResolver = _MockNavigationResolver();

    sut = RouterLogger(mockLogger);

    when(() => mockRouter.current).thenAnswer((_) => currentRouteData);
    when(() => currentRouteData.name).thenAnswer((_) => currentRouteName);
    when(() => mockResolver.routeName).thenAnswer((_) => nextRouteName);
    when(() => mockResolver.next(any())).thenAnswer((_) {});
    when(
      () => mockLogger.logDebug(
        tag: any(named: 'tag'),
        message: any(named: 'message'),
      ),
    ).thenAnswer((_) {});
  });

  test('Should log when any navigation event occurs and calls next', () async {
    sut.onNavigation(mockResolver, mockRouter);

    verify(
      () => mockLogger.logDebug(
        tag: RouterLogger.TAG,
        message: sut.buildLogMessage(currentRouteName, nextRouteName),
      ),
    );
    verify(() => mockResolver.next()).called(1);
  });
}

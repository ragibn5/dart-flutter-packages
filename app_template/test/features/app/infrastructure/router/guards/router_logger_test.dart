import 'package:app_logger/app_logger.dart';
import 'package:app_template/features/app/infrastructure/router/guards/router_logger.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

class _FakeBuildContext extends Fake implements BuildContext {}

class _FakeGoRouter extends Fake implements GoRouter {}

class _MockGoRouterState extends Mock implements GoRouterState {}

class _MockAppLogger extends Mock implements AppLogger {}

void main() {
  test('onEnterShouldLogTheNavigationAndAllowItIfCalled', () async {
    final logger = _MockAppLogger();
    final current = _MockGoRouterState();
    final next = _MockGoRouterState();
    when(() => current.matchedLocation).thenReturn('/current');
    when(() => next.matchedLocation).thenReturn('/next');

    final result = await RouterLogger(
      logger,
    ).onEnter(_FakeBuildContext(), current, next, _FakeGoRouter());

    expect(result, isA<Allow>());
    verify(
      () => logger.logInfo(
        tag: '$RouterLogger',
        message: 'Routing: /current -> /next',
      ),
    ).called(1);
  });
}

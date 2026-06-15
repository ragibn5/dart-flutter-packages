import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nav_router/nav_router.dart';

class _MockNavRouter extends Mock implements NavRouter {}

void main() {
  group('NavRouter', () {
    test('pushWithName delegates correctly', () async {
      final router = _MockNavRouter();
      when(
        () => router.pushWithName<Object?>(
          any(),
          pathParameters: any(named: 'pathParameters'),
          queryParameters: any(named: 'queryParameters'),
          extra: any(named: 'extra'),
        ),
      ).thenAnswer((_) async => null);

      await router.pushWithName('home');
      verify(() => router.pushWithName('home')).called(1);
    });

    test('replaceWithName delegates correctly', () async {
      final router = _MockNavRouter();
      when(
        () => router.replaceWithName<Object?>(
          any(),
          pathParameters: any(named: 'pathParameters'),
          queryParameters: any(named: 'queryParameters'),
          extra: any(named: 'extra'),
        ),
      ).thenAnswer((_) async => null);

      await router.replaceWithName('home');
      verify(() => router.replaceWithName('home')).called(1);
    });

    test('navigateTo delegates correctly', () {
      final router = _MockNavRouter();
      when(
        () => router.navigateTo(
          any(),
          pathParameters: any(named: 'pathParameters'),
          queryParameters: any(named: 'queryParameters'),
          extra: any(named: 'extra'),
        ),
      ).thenReturn(null);

      router.navigateTo('home');
      verify(() => router.navigateTo('home')).called(1);
    });

    test('canPopTopRoute delegates correctly', () {
      final router = _MockNavRouter();
      when(() => router.canPopTopRoute()).thenReturn(true);

      expect(router.canPopTopRoute(), isTrue);
      verify(() => router.canPopTopRoute()).called(1);
    });

    test('popTopRoute delegates correctly', () {
      final router = _MockNavRouter();
      when(() => router.popTopRoute<Object?>(any())).thenReturn(null);

      router.popTopRoute();
      verify(() => router.popTopRoute()).called(1);
    });

    test('popUntilRoute delegates correctly', () {
      final router = _MockNavRouter();
      when(() => router.popUntilRoute(any())).thenReturn(null);

      router.popUntilRoute((_) => false);
      verify(() => router.popUntilRoute(any())).called(1);
    });
  });
}

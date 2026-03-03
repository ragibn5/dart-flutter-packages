// ignore_for_file: lines_longer_than_80_chars
// ignore_for_file: avoid_redundant_argument_values
// ignore_for_file: cascade_invocations

import 'package:app_template/di/provider/dependency_provider_impl.dart';
import 'package:app_template/features/app/infrastructure/models/app_flavor.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart' hide test;
import 'package:mocktail/mocktail.dart';

class _MockGetIt extends Mock implements GetIt {}

class _MockConfigurator extends Mock {
  Future<GetIt> call(GetIt getIt, Environment? env);
}

class _FakeGetIt extends Fake implements GetIt {}

class _TestService {}

void main() {
  const flavor = AppFlavor.DEV;
  final testService = _TestService();
  final environment = Environment(flavor.name);

  late _MockGetIt mockGetIt;
  late _MockConfigurator mockConfigurator;

  setUpAll(() {
    registerFallbackValue(flavor);
    registerFallbackValue(environment);
    registerFallbackValue(testService);
    registerFallbackValue(_FakeGetIt());
  });

  setUp(() {
    mockGetIt = _MockGetIt();
    mockConfigurator = _MockConfigurator();

    when(() => mockGetIt.reset()).thenAnswer((_) async => mockGetIt);
    when(
      () =>
          mockGetIt.get<_TestService>(instanceName: any(named: 'instanceName')),
    ).thenReturn(testService);

    when(
      () => mockConfigurator(mockGetIt, any()),
    ).thenAnswer((_) async => mockGetIt);

    when(
      () => mockGetIt.registerFactory<_TestService>(
        any(),
        instanceName: any(named: 'instanceName'),
      ),
    ).thenAnswer((_) {});

    when(
      () => mockGetIt.registerSingleton<_TestService>(
        any(),
        instanceName: any(named: 'instanceName'),
        dispose: any(named: 'dispose'),
      ),
    ).thenReturn(testService);

    when(
      () => mockGetIt.registerLazySingleton<_TestService>(
        any(),
        instanceName: any(named: 'instanceName'),
        dispose: any(named: 'dispose'),
      ),
    ).thenAnswer((_) {});
  });

  test('Should call configurator if NOT already initialized', () async {
    final local = DependencyProviderImpl.test(
      mockGetIt,
      mockConfigurator.call,
      isInitialized: false,
    );

    await local.initialize(flavor);

    verify(() => mockConfigurator(mockGetIt, any())).called(1);
  });

  test('Should skip initialization if already initialized', () async {
    final provider = DependencyProviderImpl.test(
      mockGetIt,
      mockConfigurator.call,
      isInitialized: true,
    );

    await provider.initialize(null);

    verifyNever(() => mockConfigurator(any(), any()));
  });

  test(
    'Multiple initialization call should result in only one actual configure call',
    () async {
      final provider = DependencyProviderImpl.test(
        mockGetIt,
        mockConfigurator.call,
        isInitialized: false,
      );

      await provider.initialize(null);
      await provider.initialize(null);

      verify(() => mockConfigurator(any(), any())).called(1);
    },
  );

  test('dispose should call dispose on registrar (mockGetIt)', () async {
    final provider = DependencyProviderImpl.test(
      mockGetIt,
      mockConfigurator.call,
    );

    await provider.dispose();

    verify(() => mockGetIt.reset(dispose: true)).called(1);
  });

  test('getOrNull returns null if type T is not registered', () {
    final provider = DependencyProviderImpl.test(
      mockGetIt,
      mockConfigurator.call,
    );

    when(
      () => mockGetIt.isRegistered<_TestService>(
        instanceName: any(named: 'instanceName'),
      ),
    ).thenReturn(false);

    final result = provider.getOrNull<_TestService>();

    expect(result, isNull);
  });

  test(
    'getOrNull returns null if type T is registered under a different instanceName',
    () {
      final provider = DependencyProviderImpl.test(
        mockGetIt,
        mockConfigurator.call,
      );

      when(
        () => mockGetIt.isRegistered<_TestService>(instanceName: 'x'),
      ).thenReturn(false);
      when(
        () => mockGetIt.isRegistered<_TestService>(instanceName: 'y'),
      ).thenReturn(true);
      when(
        () => mockGetIt.get<_TestService>(instanceName: 'y'),
      ).thenReturn(testService);

      final resultX = provider.getOrNull<_TestService>(name: 'x');
      expect(resultX, isNull);
      final resultY = provider.getOrNull<_TestService>(name: 'y');
      expect(resultY, isNotNull);
    },
  );

  test(
    'getOrNull returns instance if type T is registered with correct name',
    () {
      final provider = DependencyProviderImpl.test(
        mockGetIt,
        mockConfigurator.call,
      );

      final mockedValue = testService;

      when(
        () => mockGetIt.isRegistered<_TestService>(
          instanceName: any(named: 'instanceName'),
        ),
      ).thenReturn(true);
      when(
        () => mockGetIt.get<_TestService>(
          instanceName: any(named: 'instanceName'),
        ),
      ).thenReturn(mockedValue);

      final result = provider.getOrNull<_TestService>();

      expect(result, equals(mockedValue));
    },
  );

  test('registerFactory throws if provider is not initialized', () {
    final provider = DependencyProviderImpl.test(
      mockGetIt,
      mockConfigurator.call,
      isInitialized: false,
    );

    expect(
      () => provider.registerFactory<_TestService>(_TestService.new),
      throwsA(isA<StateError>()),
    );

    verifyNever(
      () => mockGetIt.registerFactory<_TestService>(
        any(),
        instanceName: any(named: 'instanceName'),
      ),
    );
  });

  test('registerFactory delegates to GetIt when initialized', () {
    final provider = DependencyProviderImpl.test(
      mockGetIt,
      mockConfigurator.call,
      isInitialized: true,
    );

    _TestService factory() => testService;

    provider.registerFactory<_TestService>(factory, instanceName: 'test');

    verify(
      () => mockGetIt.registerFactory<_TestService>(
        factory,
        instanceName: 'test',
      ),
    ).called(1);
  });

  test('registerSingleton throws if provider is not initialized', () {
    final provider = DependencyProviderImpl.test(
      mockGetIt,
      mockConfigurator.call,
      isInitialized: false,
    );

    expect(
      () => provider.registerSingleton<_TestService>(testService),
      throwsA(isA<StateError>()),
    );

    verifyNever(
      () => mockGetIt.registerSingleton<_TestService>(
        any(),
        instanceName: any(named: 'instanceName'),
        dispose: any(named: 'dispose'),
      ),
    );
  });

  test('registerSingleton delegates to GetIt when initialized', () {
    final provider = DependencyProviderImpl.test(
      mockGetIt,
      mockConfigurator.call,
      isInitialized: true,
    );

    provider.registerSingleton<_TestService>(testService, instanceName: 'test');

    verify(
      () => mockGetIt.registerSingleton<_TestService>(
        testService,
        instanceName: 'test',
        dispose: any(named: 'dispose'),
      ),
    ).called(1);
  });

  test('registerLazySingleton throws if provider is not initialized', () {
    final provider = DependencyProviderImpl.test(
      mockGetIt,
      mockConfigurator.call,
      isInitialized: false,
    );

    expect(
      () => provider.registerLazySingleton<_TestService>(_TestService.new),
      throwsA(isA<StateError>()),
    );

    verifyNever(
      () => mockGetIt.registerLazySingleton<_TestService>(
        any(),
        instanceName: any(named: 'instanceName'),
        dispose: any(named: 'dispose'),
      ),
    );
  });

  test('registerLazySingleton delegates to GetIt when initialized', () {
    final provider = DependencyProviderImpl.test(
      mockGetIt,
      mockConfigurator.call,
      isInitialized: true,
    );

    _TestService factory() => testService;

    provider.registerLazySingleton<_TestService>(factory, instanceName: 'test');

    verify(
      () => mockGetIt.registerLazySingleton<_TestService>(
        factory,
        instanceName: 'test',
        dispose: any(named: 'dispose'),
      ),
    ).called(1);
  });
}

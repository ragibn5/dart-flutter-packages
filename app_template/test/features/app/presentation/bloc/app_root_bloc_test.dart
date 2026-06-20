// ignore_for_file: lines_longer_than_80_chars

import 'dart:async';

import 'package:app_logger/app_logger.dart';
import 'package:app_template/features/app/application/services/app_initializer_service.dart';
import 'package:app_template/features/app/application/services/session_initializer_service.dart';
import 'package:app_template/features/app/presentation/bloc/app_root_bloc.dart';
import 'package:app_template/features/auth/domain/models/auth_data.dart';
import 'package:app_template/features/auth/domain/services/auth_data_service.dart';
import 'package:app_template/features/settings/application/services/settings_service.dart';
import 'package:app_template/features/settings/domain/models/app_locale.dart';
import 'package:app_template/features/settings/domain/models/app_theme_mode.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockLogger extends Mock implements AppLogger {}

class _MockAuthDataService extends Mock implements AuthDataService {}

class _MockAppPreferenceService extends Mock implements SettingsService {}

class _MockAppInitializerService extends Mock
    implements AppInitializerService {}

class _MockSessionInitializerService extends Mock
    implements SessionInitializerService {}

void main() {
  late _MockLogger logger;
  late _MockAuthDataService authDataService;
  late _MockAppPreferenceService appPreferenceService;
  late _MockAppInitializerService appInitializerService;
  late _MockSessionInitializerService sessionInitializerService;

  late StreamController<AppLocale> localeController;
  late StreamController<AppThemeMode> themeController;
  late StreamController<AuthData?> authController;

  late AppRootBloc bloc;

  setUpAll(() {
    registerFallbackValue(AppLocale.EN);
    registerFallbackValue(AppThemeMode.LIGHT);
  });

  setUp(() {
    logger = _MockLogger();
    authDataService = _MockAuthDataService();
    appPreferenceService = _MockAppPreferenceService();
    appInitializerService = _MockAppInitializerService();
    sessionInitializerService = _MockSessionInitializerService();

    localeController = StreamController.broadcast();
    themeController = StreamController.broadcast();
    authController = StreamController.broadcast();

    bloc = AppRootBloc(
      logger,
      authDataService,
      appPreferenceService,
      appInitializerService,
      sessionInitializerService,
    );

    when(
      () => logger.logError(
        tag: any(named: 'tag'),
        message: any(named: 'message'),
        error: any(named: 'error'),
        stackTrace: any(named: 'stackTrace'),
      ),
    ).thenAnswer((_) {});

    when(
      () => appPreferenceService.getEffectiveLocale(),
    ).thenAnswer((_) async => .EN);
    when(
      () => appPreferenceService.getEffectiveThemeMode(),
    ).thenAnswer((_) async => .LIGHT);

    when(
      () => appPreferenceService.watchLocale(),
    ).thenAnswer((_) => localeController.stream);
    when(
      () => appPreferenceService.watchThemeMode(),
    ).thenAnswer((_) => themeController.stream);
    when(
      () => authDataService.watchAuthData(),
    ).thenAnswer((_) => authController.stream);

    when(() => appInitializerService.initialize()).thenAnswer((_) async {});
    when(() => sessionInitializerService.initialize()).thenAnswer((_) async {});
  });

  tearDown(() async {
    await localeController.close();
    await themeController.close();
    await authController.close();
  });
  blocTest<AppRootBloc, AppRootState>(
    'emits [InProgress -> Success] on AppInitializationRequested',
    build: () => bloc,
    act: (bloc) => bloc.add(AppInitializationRequested()),
    wait: const Duration(milliseconds: 100),
    expect: () => [
      isA<AppInitializationInProgress>(),
      isA<AppInitializationSuccess>()
          .having((s) => s.locale, 'locale', AppLocale.EN)
          .having((s) => s.themeMode, 'themeMode', AppThemeMode.LIGHT),
    ],
    verify: (_) async {
      verify(() => appInitializerService.initialize()).called(1);
      verify(() => sessionInitializerService.initialize()).called(1);
    },
  );

  blocTest<AppRootBloc, AppRootState>(
    'starts listening for global events on AppInitializationRequested',
    build: () => bloc,
    act: (bloc) => bloc.add(AppInitializationRequested()),
    wait: const Duration(milliseconds: 100),
    verify: (_) async {
      verify(() => appPreferenceService.watchLocale()).called(1);
      verify(() => appPreferenceService.watchThemeMode()).called(1);
      verify(() => authDataService.watchAuthData()).called(1);
    },
  );

  blocTest<AppRootBloc, AppRootState>(
    'emits AppInitializationError when app initializer throws',
    build: () {
      when(
        () => appInitializerService.initialize(),
      ).thenThrow(Exception('fail'));

      return bloc;
    },
    act: (bloc) => bloc.add(AppInitializationRequested()),
    expect: () => [
      isA<AppInitializationInProgress>(),
      isA<AppInitializationError>(),
    ],
  );

  blocTest<AppRootBloc, AppRootState>(
    're-initializes session when auth stream emits new value',
    build: () {
      when(
        () => sessionInitializerService.initialize(),
      ).thenAnswer((_) async {});

      return bloc;
    },
    act: (bloc) async {
      bloc.add(AppInitializationRequested());
      await Future<dynamic>.delayed(const Duration(milliseconds: 50));

      authController.add(null);
    },
    wait: const Duration(milliseconds: 100),
    expect: () => [
      // On initial AppInitializationRequested
      isA<AppInitializationInProgress>(),
      isA<AppInitializationSuccess>(),
      // No state changes when new auth data received
    ],
    verify: (_) {
      verify(
        () => sessionInitializerService.initialize(),
      ).called(greaterThan(1)); // once at init + once due to stream
    },
  );

  blocTest<AppRootBloc, AppRootState>(
    'updates locale when locale stream emits a value after init success',
    build: () => bloc,
    act: (bloc) async {
      bloc.add(AppInitializationRequested());
      await Future<dynamic>.delayed(const Duration(milliseconds: 50));

      // emit new locale
      localeController.add(.AR);
    },
    wait: const Duration(milliseconds: 100),
    expect: () => [
      isA<AppInitializationInProgress>(),
      isA<AppInitializationSuccess>(),
      isA<AppInitializationSuccess>().having(
        (s) => s.locale,
        'locale',
        AppLocale.AR,
      ),
    ],
  );

  blocTest<AppRootBloc, AppRootState>(
    'updates theme when theme stream emits a value after init success',
    build: () => bloc,
    act: (bloc) async {
      bloc.add(AppInitializationRequested());
      await Future<dynamic>.delayed(const Duration(milliseconds: 50));

      // emit new theme
      themeController.add(.DARK);
    },
    wait: const Duration(milliseconds: 100),
    expect: () => [
      isA<AppInitializationInProgress>(),
      isA<AppInitializationSuccess>(),
      isA<AppInitializationSuccess>().having(
        (s) => s.themeMode,
        'themeMode',
        AppThemeMode.DARK,
      ),
    ],
  );
}

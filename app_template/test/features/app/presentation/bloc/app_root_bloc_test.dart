// ignore_for_file: lines_longer_than_80_chars

import 'dart:async';

import 'package:app_logger/app_logger.dart';
import 'package:app_template/features/app/application/use_cases/get_effective_locale_use_case.dart';
import 'package:app_template/features/app/application/use_cases/get_effective_theme_mode_use_case.dart';
import 'package:app_template/features/app/application/use_cases/initialize_app_use_case.dart';
import 'package:app_template/features/app/application/use_cases/initialize_session_use_case.dart';
import 'package:app_template/features/app/application/use_cases/watch_auth_state_use_case.dart';
import 'package:app_template/features/app/application/use_cases/watch_locale_use_case.dart';
import 'package:app_template/features/app/application/use_cases/watch_theme_mode_use_case.dart';
import 'package:app_template/features/app/domain/entities/app_theme_mode.dart';
import 'package:app_template/features/app/domain/entities/locale_components.dart';
import 'package:app_template/features/app/presentation/bloc/app_root_bloc.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockLogger extends Mock implements AppLogger {}

class _MockWatchAuthStateUseCase extends Mock
    implements WatchAuthStateUseCase {}

class _MockWatchLocaleUseCase extends Mock implements WatchLocaleUseCase {}

class _MockWatchThemeModeUseCase extends Mock
    implements WatchThemeModeUseCase {}

class _MockGetEffectiveLocaleUseCase extends Mock
    implements GetEffectiveLocaleUseCase {}

class _MockGetEffectiveThemeModeUseCase extends Mock
    implements GetEffectiveThemeModeUseCase {}

class _MockInitializeAppUseCase extends Mock implements InitializeAppUseCase {}

class _MockInitializeSessionUseCase extends Mock
    implements InitializeSessionUseCase {}

void main() {
  late _MockLogger logger;
  late _MockWatchAuthStateUseCase watchAuthStateUseCase;
  late _MockWatchLocaleUseCase watchLocaleUseCase;
  late _MockWatchThemeModeUseCase watchThemeModeUseCase;
  late _MockGetEffectiveLocaleUseCase getEffectiveLocaleUseCase;
  late _MockGetEffectiveThemeModeUseCase getEffectiveThemeModeUseCase;
  late _MockInitializeAppUseCase initializeAppUseCase;
  late _MockInitializeSessionUseCase initializeSessionUseCase;

  late StreamController<LocaleComponents> localeController;
  late StreamController<AppThemeMode> themeController;
  late StreamController<bool> authController;

  late AppRootBloc bloc;

  setUpAll(() {
    registerFallbackValue(const LocaleComponents(languageCode: 'en'));
    registerFallbackValue(AppThemeMode.LIGHT);
  });

  setUp(() {
    logger = _MockLogger();
    watchAuthStateUseCase = _MockWatchAuthStateUseCase();
    watchLocaleUseCase = _MockWatchLocaleUseCase();
    watchThemeModeUseCase = _MockWatchThemeModeUseCase();
    getEffectiveLocaleUseCase = _MockGetEffectiveLocaleUseCase();
    getEffectiveThemeModeUseCase = _MockGetEffectiveThemeModeUseCase();
    initializeAppUseCase = _MockInitializeAppUseCase();
    initializeSessionUseCase = _MockInitializeSessionUseCase();

    localeController = StreamController.broadcast();
    themeController = StreamController.broadcast();
    authController = StreamController.broadcast();

    bloc = AppRootBloc(
      logger,
      watchAuthStateUseCase,
      watchLocaleUseCase,
      watchThemeModeUseCase,
      getEffectiveLocaleUseCase,
      getEffectiveThemeModeUseCase,
      initializeAppUseCase,
      initializeSessionUseCase,
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
      () => getEffectiveLocaleUseCase(),
    ).thenAnswer((_) async => const LocaleComponents(languageCode: 'en'));
    when(
      () => getEffectiveThemeModeUseCase(),
    ).thenAnswer((_) async => AppThemeMode.LIGHT);

    when(() => watchLocaleUseCase()).thenAnswer((_) => localeController.stream);
    when(
      () => watchThemeModeUseCase(),
    ).thenAnswer((_) => themeController.stream);
    when(
      () => watchAuthStateUseCase(),
    ).thenAnswer((_) => authController.stream);

    when(() => initializeAppUseCase()).thenAnswer((_) async {});
    when(() => initializeSessionUseCase()).thenAnswer((_) async {});
  });

  tearDown(() async {
    await localeController.close();
    await themeController.close();
    await authController.close();
  });

  blocTest<AppRootBloc, AppRootState>(
    'Emits [InProgress -> Success] on AppInitializationRequested',
    build: () => bloc,
    act: (bloc) => bloc.add(AppInitializationRequested()),
    wait: const Duration(milliseconds: 100),
    expect: () => [
      isA<AppInitializationInProgress>(),
      isA<AppInitializationSuccess>()
          .having(
            (s) => s.locale,
            'locale',
            const LocaleComponents(languageCode: 'en'),
          )
          .having((s) => s.themeMode, 'themeMode', AppThemeMode.LIGHT),
    ],
    verify: (_) async {
      verify(() => initializeAppUseCase()).called(1);
      verify(() => initializeSessionUseCase()).called(1);
    },
  );

  blocTest<AppRootBloc, AppRootState>(
    'Starts listening for global events on AppInitializationRequested',
    build: () => bloc,
    act: (bloc) => bloc.add(AppInitializationRequested()),
    wait: const Duration(milliseconds: 100),
    verify: (_) async {
      verify(() => watchLocaleUseCase()).called(1);
      verify(() => watchThemeModeUseCase()).called(1);
      verify(() => watchAuthStateUseCase()).called(1);
    },
  );

  blocTest<AppRootBloc, AppRootState>(
    'Emits AppInitializationError when app initializer throws',
    build: () {
      when(() => initializeAppUseCase()).thenThrow(Exception('fail'));

      return bloc;
    },
    act: (bloc) => bloc.add(AppInitializationRequested()),
    expect: () => [
      isA<AppInitializationInProgress>(),
      isA<AppInitializationError>(),
    ],
  );

  blocTest<AppRootBloc, AppRootState>(
    'Re-initializes session when auth stream emits new value',
    build: () {
      when(() => initializeSessionUseCase()).thenAnswer((_) async {});

      return bloc;
    },
    act: (bloc) async {
      bloc.add(AppInitializationRequested());
      await Future<dynamic>.delayed(const Duration(milliseconds: 50));

      authController.add(true);
    },
    wait: const Duration(milliseconds: 100),
    expect: () => [
      isA<AppInitializationInProgress>(),
      isA<AppInitializationSuccess>(),
    ],
    verify: (_) {
      verify(() => initializeSessionUseCase()).called(greaterThan(1));
    },
  );

  blocTest<AppRootBloc, AppRootState>(
    'Does not update locale when locale stream emits a value and state is not AppInitializationSuccess',
    build: () => bloc,
    act: (_) =>
        localeController.add(const LocaleComponents(languageCode: 'ar')),
    expect: () => <AppRootState>[],
  );

  blocTest<AppRootBloc, AppRootState>(
    'Updates locale when locale stream emits a value after init success',
    build: () => bloc,
    act: (bloc) async {
      bloc.add(AppInitializationRequested());
      await Future<dynamic>.delayed(const Duration(milliseconds: 50));
      localeController.add(const LocaleComponents(languageCode: 'ar'));
    },
    wait: const Duration(milliseconds: 100),
    expect: () => [
      isA<AppInitializationInProgress>(),
      isA<AppInitializationSuccess>().having(
        (s) => s.locale,
        'locale',
        const LocaleComponents(languageCode: 'en'),
      ),
      isA<AppInitializationSuccess>().having(
        (s) => s.locale,
        'locale',
        const LocaleComponents(languageCode: 'ar'),
      ),
    ],
  );

  blocTest<AppRootBloc, AppRootState>(
    'Does not update theme when theme stream emits a value and state is not AppInitializationSuccess',
    build: () => bloc,
    act: (_) => themeController.add(AppThemeMode.DARK),
    expect: () => <AppRootState>[],
  );

  blocTest<AppRootBloc, AppRootState>(
    'Updates theme when theme stream emits a value after init success',
    build: () => bloc,
    act: (bloc) async {
      bloc.add(AppInitializationRequested());
      await Future<dynamic>.delayed(const Duration(milliseconds: 50));
      themeController.add(AppThemeMode.DARK);
    },
    wait: const Duration(milliseconds: 100),
    expect: () => [
      isA<AppInitializationInProgress>(),
      isA<AppInitializationSuccess>().having(
        (s) => s.themeMode,
        'themeMode',
        AppThemeMode.LIGHT,
      ),
      isA<AppInitializationSuccess>().having(
        (s) => s.themeMode,
        'themeMode',
        AppThemeMode.DARK,
      ),
    ],
  );

  blocTest<AppRootBloc, AppRootState>(
    'Does not update locale on SystemLocaleChanged if state is not AppInitializationSuccess',
    build: () => bloc,
    act: (bloc) => bloc.add(SystemLocaleChanged()),
    expect: () => <AppRootState>[],
  );

  blocTest<AppRootBloc, AppRootState>(
    'Updates locale on SystemLocaleChanged after init success',
    build: () {
      var callCount = 0;
      when(() => getEffectiveLocaleUseCase()).thenAnswer((_) async {
        callCount++;
        if (callCount == 1) {
          return const LocaleComponents(languageCode: 'en');
        } else {
          return const LocaleComponents(languageCode: 'ar');
        }
      });
      return bloc;
    },
    act: (bloc) async {
      bloc.add(AppInitializationRequested());
      await Future<dynamic>.delayed(const Duration(milliseconds: 50));
      bloc.add(SystemLocaleChanged());
    },
    wait: const Duration(milliseconds: 100),
    expect: () => [
      isA<AppInitializationInProgress>(),
      isA<AppInitializationSuccess>().having(
        (s) => s.locale,
        'locale',
        const LocaleComponents(languageCode: 'en'),
      ),
      isA<AppInitializationSuccess>().having(
        (s) => s.locale,
        'locale',
        const LocaleComponents(languageCode: 'ar'),
      ),
    ],
  );

  blocTest<AppRootBloc, AppRootState>(
    'Does not update theme on SystemBrightnessModeChanged if state is not AppInitializationSuccess',
    build: () => bloc,
    act: (bloc) => bloc.add(SystemBrightnessModeChanged()),
    expect: () => <AppRootState>[],
  );

  blocTest<AppRootBloc, AppRootState>(
    'Updates theme mode on SystemBrightnessModeChanged after init success',
    build: () {
      var callCount = 0;
      when(() => getEffectiveThemeModeUseCase()).thenAnswer((_) async {
        callCount++;
        if (callCount == 1) {
          return AppThemeMode.LIGHT;
        } else {
          return AppThemeMode.DARK;
        }
      });
      return bloc;
    },
    act: (bloc) async {
      bloc.add(AppInitializationRequested());
      await Future<dynamic>.delayed(const Duration(milliseconds: 50));
      bloc.add(SystemBrightnessModeChanged());
    },
    wait: const Duration(milliseconds: 100),
    expect: () => [
      isA<AppInitializationInProgress>(),
      isA<AppInitializationSuccess>().having(
        (s) => s.themeMode,
        'themeMode',
        AppThemeMode.LIGHT,
      ),
      isA<AppInitializationSuccess>().having(
        (s) => s.themeMode,
        'themeMode',
        AppThemeMode.DARK,
      ),
    ],
  );
}

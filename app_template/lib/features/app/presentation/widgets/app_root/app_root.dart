import 'package:app_template/features/app/infrastructure/models/app_config.dart';
import 'package:app_template/features/app/presentation/bloc/app_bloc.dart';
import 'package:app_template/features/app/presentation/widgets/startup_error/startup_error_page.dart';
import 'package:app_template/features/app/presentation/widgets/startup_loader/startup_loader_page.dart';
import 'package:app_template/features/auth/domain/services/auth_data_service.dart';
import 'package:app_template/generated/l10n.dart';
import 'package:app_template/router/app_router.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// The root widget of the app.
///
/// This widget is omni present, as long as the app is running.
class AppRoot extends StatefulWidget {
  /// The router to use.
  final AppRouter router;

  /// The AuthDataService to set up the router config.
  final AuthDataService authDataService;

  /// The platform config used to load the app.
  final AppConfig platformConfig;

  /// Global scaffold messenger key.
  /// This is used to present snacks and dialogs from anywhere within the app.
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey;

  const AppRoot({
    super.key,
    required this.router,
    required this.authDataService,
    required this.platformConfig,
    required this.scaffoldMessengerKey,
  });

  @override
  State<AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<AppRoot> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppBloc, AppState>(
      builder: (_, state) => ScreenUtilInit(
        designSize: widget.platformConfig.designSize,
        builder: (_, child) => MaterialApp.router(
          restorationScopeId: widget.platformConfig.restorationScopeId,
          scaffoldMessengerKey: widget.scaffoldMessengerKey,
          localizationsDelegates: widget.platformConfig.localizationDelegates,
          supportedLocales: widget.platformConfig.supportedLocales,
          locale: _extractLocale(state, widget.platformConfig),
          theme: widget.platformConfig.lightThemeData,
          darkTheme: widget.platformConfig.darkThemeData,
          themeMode: _extractThemeMode(state, widget.platformConfig),
          onGenerateTitle: (context) => S.of(context).appTitle,
          routerConfig: _buildRouterConfig(),
          builder: (_, child) => _StateAwareRootPage(
            platformConfig: widget.platformConfig,
            state: state,
            child: child,
          ),
        ),
      ),
    );
  }

  @override
  Future<void> didChangePlatformBrightness() async {
    super.didChangePlatformBrightness();
    context.read<AppBloc>().add(SystemBrightnessModeChanged());
  }

  RouterConfig<Object>? _buildRouterConfig() {
    return widget.router.config(
      reevaluateListenable: ReevaluateListenable.stream(
        widget.authDataService.watchAuthData(),
      ),
    );
  }

  Locale _extractLocale(AppState state, AppConfig platformConfig) {
    return state is AppInitializationSuccess
        ? state.locale
        : platformConfig.defaultLocale;
  }

  ThemeMode _extractThemeMode(AppState state, AppConfig platformConfig) {
    return state is AppInitializationSuccess
        ? state.themeMode
        : platformConfig.defaultThemeMode;
  }
}

class _StateAwareRootPage extends StatelessWidget {
  final AppConfig platformConfig;
  final AppState state;
  final Widget? child;

  const _StateAwareRootPage({
    super.key,
    required this.platformConfig,
    required this.state,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    final scopedState = state;
    switch (scopedState) {
      case AppInitializationInitial() || AppInitializationInProgress():
        return const StartupLoaderPage();
      case AppInitializationError():
        return StartupErrorPage(
          errorTitle: scopedState.errorTitle,
          errorDescription: scopedState.errorDescription,
          stackTrace: scopedState.stackTrace,
          onRetry: () =>
              context.read<AppBloc>().add(AppInitializationRequested()),
        );
      case AppInitializationSuccess():
        return child ??
            StartupErrorPage(
              errorTitle: 'Internal error',
              errorDescription: 'No initial route or widget was found',
              onRetry: () =>
                  context.read<AppBloc>().add(AppInitializationRequested()),
            );
    }
  }
}

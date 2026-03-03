part of 'app_root.dart';

class _StartupErrorPage extends StatelessWidget {
  const _StartupErrorPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 8,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                color: AppColors.error,
                size: 32,
              ),
              Text(S.of(context).startupGenericErrorMessage),
              TextButton(
                onPressed: () => handleRetry(context),
                child: Text(S.of(context).retry),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void handleRetry(BuildContext context) {
    context.read<AppBloc>().add(AppInitializationRequested());
  }
}

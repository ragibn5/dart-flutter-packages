import 'package:app_template/features/app/presentation/bloc/startup_error_reporter_bloc.dart';
import 'package:app_template/features/app/presentation/widgets/startup_error/startup_error_reporter_ui.dart';
import 'package:app_template/features/reporting/domain/models/error_report.dart';
import 'package:common_widgets/common_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// A page to show top level errors of the application.
///
/// ***Note:***
/// This page was designed to be used before the app components are
/// initialized, or before the app is ready to use. So avoid dependencies
/// that require initialized app services.
///
class StartupErrorPage extends StatelessWidget {
  final ErrorReport errorReport;

  final void Function()? onRetry;

  const StartupErrorPage({super.key, required this.errorReport, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16).copyWith(top: 48),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(
                Icons.error_rounded,
                color: Theme.of(context).colorScheme.error,
                size: 48,
              ),

              const SizedBox(height: 8),

              Text(
                'App Error'.toUpperCase(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.error,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Help us improve by sharing the error report',
                maxLines: 1,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 32),

              if (onRetry == null) ...[
                TitledWidget.noSpacing(
                  title: const Text('Retry', style: TextStyle(fontSize: 12)),
                  child: IconButton.filled(
                    icon: const Icon(Icons.replay),
                    onPressed: () => onRetry?.call(),
                  ),
                ),
                const SizedBox(height: 32),
              ],

              const Spacer(),

              BlocProvider(
                create: (_) => StartupErrorReporterBloc(),
                child: StartupErrorReporterUi(errorReport: errorReport),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

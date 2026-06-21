import 'package:app_template/features/app/presentation/bloc/startup_error_reporter_bloc.dart';
import 'package:app_template/features/reporting/domain/models/error_report.dart';
import 'package:common_widgets/common_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class StartupErrorReporterUi extends StatelessWidget {
  final ErrorReport errorReport;

  final void Function()? onRetry;

  const StartupErrorReporterUi({
    super.key,
    required this.errorReport,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StartupErrorReporterBloc, StartupErrorReporterState>(
      builder: (context, state) {
        return switch (state) {
          StartupErrorReporterStateInitial() => TitledWidget.noSpacing(
            title: const Text('Send report', style: TextStyle(fontSize: 12)),
            child: _SendButton(onTap: () => _callSendErrorReportEvent(context)),
          ),

          StartupErrorReporterStateSending() => TitledWidget.noSpacing(
            title: const Text(
              'Sending report...',
              style: TextStyle(fontSize: 12),
            ),
            child: Container(
              width: 48,
              height: 48,
              padding: const EdgeInsets.all(12),
              child: const CircularProgressIndicator(strokeWidth: 2),
            ),
          ),

          StartupErrorReporterStateReported() => const TitledWidget.noSpacing(
            title: Text('Report sent, thanks!', style: TextStyle(fontSize: 12)),
            child: Padding(
              padding: EdgeInsets.all(12),
              child: Icon(Icons.check, color: Colors.green, size: 24),
            ),
          ),

          StartupErrorReporterStateError() => TitledWidget.noSpacing(
            title: Text(
              'Error sending report, please retry.',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.error,
              ),
            ),
            child: _SendButton(onTap: () => _callSendErrorReportEvent(context)),
          ),
        };
      },
    );
  }

  void _callSendErrorReportEvent(BuildContext context) {
    context.read<StartupErrorReporterBloc>().add(SendErrorReport(errorReport));
  }
}

class _SendButton extends StatelessWidget {
  final void Function() onTap;

  const _SendButton({
    // ignore: unused_element_parameter
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton.filled(
      icon: const Icon(Icons.send, size: 24),
      onPressed: onTap,
    );
  }
}

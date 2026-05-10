import 'package:app_template/main_common.dart';
import 'package:flutter/material.dart';
import 'package:string_extensions/string_extensions.dart';

/// A page to show top level errors of the application.
///
/// ***Note:***
/// This page was designed to be and used before the app components are
/// initialized, or before the app is ready to use. So, if you are modifying
/// this file, don't use things that requires app components to be initialized.
/// See the [runFlavoredApp] for more info.
///
class StartupErrorPage extends StatelessWidget {
  final String errorTitle;

  final String? errorDescription;
  final StackTrace? stackTrace;
  final void Function()? onRetry;

  const StartupErrorPage({
    super.key,
    required this.errorTitle,
    this.errorDescription,
    this.stackTrace,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              spacing: 8,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_rounded,
                  color: Colors.redAccent,
                  size: 48,
                ),
                Text(
                  errorTitle.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.redAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Flexible(
                  child: Text(
                    errorDescription.nullOnEmptyOrBlank ??
                        'Please contact support.',
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
                if (onRetry != null)
                  IconButton(
                    onPressed: onRetry,
                    color: Colors.blueAccent,
                    icon: const Icon(Icons.replay),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

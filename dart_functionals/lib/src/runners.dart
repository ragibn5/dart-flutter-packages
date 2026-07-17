import 'dart:developer';

T runCatching<T>(
  T Function() runnable, {
  required T defaultValue,
  bool printErrorLog = false,
}) {
  try {
    return runnable();
  } catch (e, st) {
    if (printErrorLog) {
      log('Error while running runnable', error: e, stackTrace: st);
    }
    return defaultValue;
  }
}

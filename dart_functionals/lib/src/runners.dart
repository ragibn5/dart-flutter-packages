import 'dart:developer';

T runCatching<T>(
  T Function() runnable, {
  required T defaultValue,
  bool printLog = false,
}) {
  try {
    return runnable();
  } catch (e, st) {
    if (printLog) {
      log('Error while running runnable', error: e, stackTrace: st);
    }
    return defaultValue;
  }
}

import 'dart:developer';

T runCatching<T>(T Function() runnable, {required T defaultValue}) {
  try {
    return runnable();
  } catch (e, st) {
    log('Error while running runnable', error: e, stackTrace: st);
    return defaultValue;
  }
}

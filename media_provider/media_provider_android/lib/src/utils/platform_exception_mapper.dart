import 'package:flutter/services.dart';

Future<T> guardPlatformCall<T>(
  Future<T> Function() call,
  Exception Function(PlatformException) mapper,
) async {
  try {
    return await call();
  } on PlatformException catch (e, stackTrace) {
    Error.throwWithStackTrace(mapper(e), stackTrace);
  }
}

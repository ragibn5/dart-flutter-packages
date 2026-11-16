import 'package:document_tree_android/src/exceptions/platform_exception_mapper.dart';
import 'package:flutter/services.dart';

Future<T> guardPlatformCall<T>(
  PlatformExceptionMapper mapper,
  Future<T> Function() call,
) async {
  try {
    return await call();
  } on PlatformException catch (e, stackTrace) {
    Error.throwWithStackTrace(mapper.map(e), stackTrace);
  }
}

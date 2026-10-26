import 'package:flutter/services.dart';

abstract interface class PlatformExceptionMapper {
  Exception map(PlatformException e);
}

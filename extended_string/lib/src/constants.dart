import 'dart:io';

final class Constants {
  // Never created: it only holds static members.
  Constants._(); // coverage:ignore-line

  static final lineSeparator = Platform.isWindows ? '\r\n' : '\n';
}

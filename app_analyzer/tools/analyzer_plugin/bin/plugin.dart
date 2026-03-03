import 'dart:isolate';

import 'package:app_analyzer/app_analyzer.dart';

void main(List<String> args, SendPort sendPort) {
  startAnalysisPluginServer(args, sendPort);
}

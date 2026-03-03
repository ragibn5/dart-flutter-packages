import 'dart:io';

final String versionInfo = '''
App analyzer v0.0.1
Dart SDK: ${Platform.version}

''';

const helpText = '''
flutter_app_analyzer_plugin - Analyzer plugin for the enclosing app/package.

Usage:
  flutter_app_analyzer_plugin analyze [options]
  
Options:
  -h, --help           Show this help message
  -v, --version        Show version information

Analyze Options:
  -d, --dir=<PATH>     Analysis directory (default: current directory)

Examples:
  # Analyze current directory
  flutter_app_analyzer_plugin analyze
  
  # Analyze specific directory
  flutter_app_analyzer_plugin analyze -d ~/projects/my_app
  
  # Show version info
  flutter_app_analyzer_plugin -v
  
  # Show help
  flutter_app_analyzer_plugin -h
  
''';

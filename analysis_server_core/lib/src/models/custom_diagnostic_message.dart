import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/diagnostic/diagnostic.dart';

/// A mirror class created from _fe_analyzer_shared package's
/// internal implementation as it was not directly exposed to us.
///
/// Can be used to provide contextual information while reporting any nodes
/// via [AnalysisRule.reportAt*()] calls.
class CustomDiagnosticMessage implements DiagnosticMessage {
  @override
  final String filePath;

  @override
  final int length;

  final String _message;

  @override
  final int offset;

  @override
  final String? url;

  CustomDiagnosticMessage({
    required this.filePath,
    required this.length,
    required String message,
    required this.offset,
    required this.url,
  }) : _message = message;

  @override
  String messageText({required bool includeUrl}) {
    if (includeUrl && url != null) {
      final result = StringBuffer(_message);
      if (!_message.endsWith('.')) {
        result.write('.');
      }
      result.write('  See $url');
      return result.toString();
    }
    return _message;
  }

  static CustomDiagnosticMessage? fromNode(
    AstNode node, {
    required String message,
    String? url,
  }) {
    final unit = node.thisOrAncestorOfType<CompilationUnit>();
    final source = unit?.declaredFragment?.source;

    if (source == null) {
      return null;
    }

    return CustomDiagnosticMessage(
      filePath: source.fullName,
      offset: node.offset,
      length: node.length,
      message: message,
      url: url,
    );
  }
}

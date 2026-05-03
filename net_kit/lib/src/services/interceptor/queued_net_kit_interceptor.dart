import 'dart:async';

import 'package:net_kit/net_kit.dart';

/// Serializes interceptor request hooks to prevent race conditions.
///
/// When multiple requests arrive concurrently, they are queued and processed
/// one at a time in arrival order. This is useful for auth token refresh,
/// rate limiting, and similar scenarios.
///
/// Responses and errors are NOT queued — they fire naturally as they arrive.
abstract class QueuedNetKitInterceptor extends NetKitInterceptor {
  final _queue = <_QueuedTask>[];
  var _isProcessing = false;

  @override
  Future<RequestInterceptorResult> onRequest(RequestSpec request) async {
    final completer = Completer<RequestInterceptorResult>();
    _queue.add(_QueuedTask(request, completer));
    _drain();
    return completer.future;
  }

  void _drain() {
    if (_isProcessing || _queue.isEmpty) return;
    _isProcessing = true;
    _processNext();
  }

  Future<void> _processNext() async {
    final task = _queue.removeAt(0);
    try {
      final result = await super.onRequest(task.request);
      task.completer.complete(result);
    } catch (e) {
      task.completer.completeError(e);
    } finally {
      _isProcessing = false;
      _drain();
    }
  }
}

class _QueuedTask {
  final RequestSpec request;
  final Completer<RequestInterceptorResult> completer;

  _QueuedTask(this.request, this.completer);
}

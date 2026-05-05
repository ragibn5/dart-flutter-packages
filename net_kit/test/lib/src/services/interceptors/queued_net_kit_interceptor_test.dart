import 'dart:async';

import 'package:net_kit/net_kit.dart';
import 'package:test/test.dart';

class _TestQueuedInterceptor extends QueuedNetKitInterceptor {
  final Future<RequestInterceptorResult> Function(RequestSpec request)?
      requestHandler;
  final Future<ResponseInterceptorResult> Function(RawResponse response)?
      responseHandler;
  final Future<ErrorInterceptorResult> Function(NetKitException error)?
      errorHandler;

  _TestQueuedInterceptor({
    this.requestHandler,
    this.responseHandler,
    this.errorHandler,
  });

  @override
  Future<RequestInterceptorResult> handleRequest(RequestSpec request) async {
    final handler = requestHandler;
    if (handler != null) return handler(request);
    return super.handleRequest(request);
  }

  @override
  Future<ResponseInterceptorResult> handleResponse(RawResponse response) async {
    final handler = responseHandler;
    if (handler != null) return handler(response);
    return super.handleResponse(response);
  }

  @override
  Future<ErrorInterceptorResult> handleError(NetKitException error) async {
    final handler = errorHandler;
    if (handler != null) return handler(error);
    return super.handleError(error);
  }
}

void main() {
  RequestSpec request(String path) {
    return RequestSpec(pathOrUrl: path, method: HttpMethod.GET);
  }

  RawResponse response(String body) {
    return RawResponse(
      statusCode: 200,
      rawResponseBody: body,
      responseHeaders: const {},
      request: request('/source'),
    );
  }

  test('Processes requests in arrival order', () async {
    final events = <String>[];
    final firstStarted = Completer<void>();
    final releaseFirst = Completer<void>();

    final sut = _TestQueuedInterceptor(
      requestHandler: (request) async {
        events.add('${request.pathOrUrl}-start');
        if (request.pathOrUrl == '/first') {
          firstStarted.complete();
          await releaseFirst.future;
        }
        events.add('${request.pathOrUrl}-end');
        return ContinueWithRequest(request);
      },
    );

    final firstFuture = sut.onRequest(request('/first'));
    await firstStarted.future;

    final secondFuture = sut.onRequest(request('/second'));
    await Future<void>.delayed(Duration.zero);

    expect(events, ['/first-start']);

    releaseFirst.complete();

    await Future.wait([firstFuture, secondFuture]);

    expect(
      events,
      ['/first-start', '/first-end', '/second-start', '/second-end'],
    );
  });

  test('Processes responses in arrival order', () async {
    final events = <String>[];
    final firstStarted = Completer<void>();
    final releaseFirst = Completer<void>();

    final sut = _TestQueuedInterceptor(
      responseHandler: (response) async {
        final marker = response.rawResponseBody as String;
        events.add('$marker-start');
        if (marker == 'first') {
          firstStarted.complete();
          await releaseFirst.future;
        }
        events.add('$marker-end');
        return ContinueWithResponse(response);
      },
    );

    final firstFuture = sut.onResponse(response('first'));
    await firstStarted.future;

    final secondFuture = sut.onResponse(response('second'));
    await Future<void>.delayed(Duration.zero);

    expect(events, ['first-start']);

    releaseFirst.complete();

    await Future.wait([firstFuture, secondFuture]);

    expect(
      events,
      ['first-start', 'first-end', 'second-start', 'second-end'],
    );
  });

  test('Processes errors in arrival order', () async {
    final events = <String>[];
    final firstStarted = Completer<void>();
    final releaseFirst = Completer<void>();

    final sut = _TestQueuedInterceptor(
      errorHandler: (error) async {
        final marker = (error as UnexpectedException).message;
        events.add('$marker-start');
        if (marker == 'first') {
          firstStarted.complete();
          await releaseFirst.future;
        }
        events.add('$marker-end');
        return ContinueWithError(error);
      },
    );

    final firstFuture = sut.onError(const UnexpectedException('first'));
    await firstStarted.future;

    final secondFuture = sut.onError(const UnexpectedException('second'));
    await Future<void>.delayed(Duration.zero);

    expect(events, ['first-start']);

    releaseFirst.complete();

    await Future.wait([firstFuture, secondFuture]);

    expect(
      events,
      ['first-start', 'first-end', 'second-start', 'second-end'],
    );
  });

  test('Does not block one phase on another phase', () async {
    final events = <String>[];
    final requestStarted = Completer<void>();
    final responseStarted = Completer<void>();
    final releaseRequest = Completer<void>();
    final releaseResponse = Completer<void>();

    final sut = _TestQueuedInterceptor(
      requestHandler: (request) async {
        events.add('request-start');
        requestStarted.complete();
        await releaseRequest.future;
        events.add('request-end');
        return ContinueWithRequest(request);
      },
      responseHandler: (response) async {
        events.add('response-start');
        responseStarted.complete();
        await releaseResponse.future;
        events.add('response-end');
        return ContinueWithResponse(response);
      },
    );

    final requestFuture = sut.onRequest(request('/first'));
    await requestStarted.future;

    final responseFuture = sut.onResponse(response('first'));
    await responseStarted.future;

    expect(events, ['request-start', 'response-start']);

    releaseRequest.complete();
    releaseResponse.complete();

    await Future.wait([requestFuture, responseFuture]);

    expect(events, [
      'request-start',
      'response-start',
      'request-end',
      'response-end',
    ]);
  });
}

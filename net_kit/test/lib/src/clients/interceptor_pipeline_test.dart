// ignore_for_file: cascade_invocations

import 'package:net_kit/net_kit.dart';
import 'package:test/test.dart';

class _FakeInterceptor extends NetKitInterceptor {}

void main() {
  test('Starts empty', () {
    final pipeline = InterceptorPipeline();
    expect(pipeline.isEmpty, isTrue);
    expect(pipeline.length, 0);
    expect(pipeline.snapshot(), isEmpty);
  });

  test('Add appends interceptors in order', () {
    final a = _FakeInterceptor();
    final b = _FakeInterceptor();
    final pipeline = InterceptorPipeline();

    pipeline.add(a);
    pipeline.add(b);

    expect(pipeline.snapshot(), orderedEquals([a, b]));
    expect(pipeline.length, 2);
  });

  test('Remove removes the first matching interceptor and returns true', () {
    final a = _FakeInterceptor();
    final b = _FakeInterceptor();
    final pipeline = InterceptorPipeline(interceptors: [a, b]);

    final removed = pipeline.remove(a);

    expect(removed, isTrue);
    expect(pipeline.snapshot(), orderedEquals([b]));
    expect(pipeline.length, 1);
  });

  test('Remove returns false when interceptor is not present', () {
    final pipeline = InterceptorPipeline();
    final removed = pipeline.remove(_FakeInterceptor());
    expect(removed, isFalse);
  });

  test('Clear removes all interceptors', () {
    final pipeline = InterceptorPipeline(
      interceptors: [_FakeInterceptor(), _FakeInterceptor()],
    );
    pipeline.clear();
    expect(pipeline.isEmpty, isTrue);
    expect(pipeline.length, 0);
  });

  test('Snapshot returns a copy', () {
    final a = _FakeInterceptor();
    final b = _FakeInterceptor();
    final pipeline = InterceptorPipeline(interceptors: [a, b]);

    final snapshot = pipeline.snapshot();
    pipeline.clear();

    expect(snapshot, hasLength(2));
    expect(pipeline.isEmpty, isTrue);
  });

  test('Accepts initial interceptors via constructor', () {
    final a = _FakeInterceptor();
    final pipeline = InterceptorPipeline(interceptors: [a]);

    expect(pipeline.snapshot(), contains(a));
    expect(pipeline.length, 1);
  });
}

import 'package:content_io_android/content_io_android_method_channel.dart';
import 'package:content_io_android/src/io/source/content_byte_source.dart';
import 'package:content_io_android/src/io/source/content_byte_source_factory.dart';
import 'package:content_io_android/src/models/open_read_request.dart';
import 'package:content_io_android/src/models/open_thumbnail_read_request.dart';
import 'package:content_io_android/src/models/thumbnail_size.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockSourceFactory extends Mock implements ContentByteSourceFactory {}

class _MockSource extends Mock implements ContentByteSource {}

void main() {
  late _MockSourceFactory sourceFactory;
  late MethodChannelContentIoAndroid sut;

  setUp(() {
    sourceFactory = _MockSourceFactory();
    sut = MethodChannelContentIoAndroid(sourceFactory: sourceFactory);
  });

  test('openReadSessionShouldReadFromSourceFactoryOpens', () async {
    const request = OpenReadRequest(uri: 'content://media/1');
    final source = _MockSource();
    when(() => source.id).thenReturn('local-1');
    when(() => sourceFactory.open(request)).thenAnswer((_) async => source);

    final session = await sut.openReadSession(request);

    expect(session.sessionId, 'local-1');
  });

  test('openThumbnailReadSessionShouldReadFromSourceFactoryOpens', () async {
    const request = OpenThumbnailReadRequest(
      uri: 'content://media/1',
      size: ThumbnailSize(width: 256, height: 256),
    );
    final source = _MockSource();
    when(() => source.id).thenReturn('session-1');
    when(
      () => sourceFactory.openThumbnail(request),
    ).thenAnswer((_) async => source);

    final session = await sut.openThumbnailReadSession(request);

    expect(session.sessionId, 'session-1');
  });
}

import 'dart:async';

import 'package:dio/dio.dart';
import 'package:net_kit/src/models/file_source.dart';
import 'package:net_kit/src/models/multipart_file_part.dart';
import 'package:net_kit/src/models/raw_data.dart';
import 'package:net_kit/src/models/request_body.dart';
import 'package:net_kit/src/services/transformers/request/dio_request_body_transformer.dart';
import 'package:net_kit/src/services/transformers/request/request_body_transformer.dart';
import 'package:test/test.dart';

void main() {
  late RequestBodyTransformer requestBodyTransformer;

  setUp(() {
    requestBodyTransformer = const DioRequestBodyTransformer();
  });

  test('Null bodies are transformed to null', () {
    final result = requestBodyTransformer.transform(null);

    expect(result, isNull);
  });

  test('RawString bodies are transformed to the raw string value', () {
    final result = requestBodyTransformer.transform(
      const RawBody(
        RawString('payload'),
        contentType: 'text/plain',
      ),
    );

    expect(result, 'payload');
  });

  test('RawBytes bodies are transformed to the raw byte list', () {
    final result = requestBodyTransformer.transform(
      const RawBody(
        RawBytes([1, 2, 3]),
        contentType: 'application/octet-stream',
      ),
    );

    expect(result, [1, 2, 3]);
  });

  test('RawStream bodies are transformed to the original stream', () async {
    final stream = Stream<List<int>>.value([1, 2, 3]);

    final result = requestBodyTransformer.transform(
      RawBody(
        RawStream(3, stream),
        contentType: 'application/octet-stream',
      ),
    );

    expect(await (result as Stream<List<int>>).toList(), [
      [1, 2, 3],
    ]);
  });

  test('Json bodies are transformed to the original json map', () {
    final result = requestBodyTransformer.transform(
      const JsonBody({'name': 'net_kit'}),
    );

    expect(result, {'name': 'net_kit'});
  });

  test('FormUrlEncoded bodies are transformed to the original fields', () {
    final result = requestBodyTransformer.transform(
      const FormUrlEncodedBody(fields: {'name': 'net_kit'}),
    );

    expect(result, {'name': 'net_kit'});
  });

  test('Multipart bodies are transformed to dio FormData', () {
    final streamController = StreamController<List<int>>();
    final result = requestBodyTransformer.transform(
      MultipartBody(
        fields: const {'title': 'avatar'},
        files: [
          const MultipartFilePart(
            fieldName: 'bytes',
            fileName: 'avatar.bin',
            source: BytesSource([1, 2, 3]),
            contentType: 'application/octet-stream',
            headers: {'x-file': 'bytes'},
          ),
          MultipartFilePart(
            fieldName: 'stream',
            fileName: 'avatar.txt',
            source: StreamSource(4, streamController.stream),
            contentType: 'text/plain',
            headers: const {'x-file': 'stream'},
          ),
        ],
      ),
    );

    final formData = result as FormData;

    expect(formData.fields, hasLength(1));
    expect(formData.fields.single.key, 'title');
    expect(formData.fields.single.value, 'avatar');
    expect(formData.files, hasLength(2));
    expect(formData.files.first.key, 'bytes');
    expect(formData.files.first.value.filename, 'avatar.bin');
    expect(
      formData.files.first.value.contentType.toString(),
      'application/octet-stream',
    );
    expect(formData.files.first.value.headers, {
      'x-file': ['bytes'],
    });
    expect(formData.files.last.key, 'stream');
    expect(formData.files.last.value.filename, 'avatar.txt');
    expect(formData.files.last.value.length, 4);
    expect(formData.files.last.value.contentType.toString(), 'text/plain');
    expect(formData.files.last.value.headers, {
      'x-file': ['stream'],
    });

    unawaited(streamController.close());
  });
}

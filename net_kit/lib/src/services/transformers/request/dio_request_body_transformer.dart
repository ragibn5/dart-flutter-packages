import 'package:dio/dio.dart';
import 'package:net_kit/src/models/file_source.dart';
import 'package:net_kit/src/models/multipart_file_part.dart';
import 'package:net_kit/src/models/raw_data.dart';
import 'package:net_kit/src/models/request_body.dart';
import 'package:net_kit/src/services/transformers/request/request_body_transformer.dart';

class DioRequestBodyTransformer implements RequestBodyTransformer {
  const DioRequestBodyTransformer();

  @override
  dynamic transform(RequestBody? body) {
    return switch (body) {
      RawBody(data: final data) => _transformRawData(data),
      JsonBody(data: final data) => data,
      FormUrlEncodedBody(fields: final fields) => fields,
      MultipartBody(fields: final fields, files: final files) =>
        _transformMultipartBody(fields, files),
      null => null,
    };
  }

  dynamic _transformRawData(RawData data) {
    return switch (data) {
      RawString(value: final value) => value,
      RawBytes(bytes: final bytes) => bytes,
      RawStream(stream: final stream) => stream,
    };
  }

  FormData _transformMultipartBody(
    Map<String, String> fields,
    List<MultipartFilePart> files,
  ) {
    final formData = FormData();
    formData.fields.addAll(fields.entries);
    formData.files.addAll(
      files.map(
        (file) => MapEntry(
          file.fieldName,
          _transformMultipartFile(file),
        ),
      ),
    );
    return formData;
  }

  MultipartFile _transformMultipartFile(MultipartFilePart file) {
    final contentType =
        file.contentType == null ? null : DioMediaType.parse(file.contentType!);
    final headers =
        file.headers?.map((key, value) => MapEntry(key, <String>[value]));

    return switch (file.source) {
      BytesSource(bytes: final bytes) => MultipartFile.fromBytes(
          bytes,
          filename: file.fileName,
          contentType: contentType,
          headers: headers,
        ),
      StreamSource(length: final length, stream: final stream) =>
        MultipartFile.fromStream(
          () => stream,
          length,
          filename: file.fileName,
          contentType: contentType,
          headers: headers,
        ),
    };
  }
}

import 'package:net_kit/src/models/multipart_field.dart';
import 'package:net_kit/src/models/multipart_file_part.dart';

sealed class RequestBody<Req> {
  const RequestBody();
}

final class EncodableRequestBody<Req> extends RequestBody<Req> {
  /// An encodable strongly typed data of the request body.
  final Req data;

  const EncodableRequestBody(this.data);
}

final class FormUrlEncodedRequestBody extends RequestBody<Never> {
  /// Key-value pairs encoded as `application/x-www-form-urlencoded`.
  final Map<String, dynamic> fields;

  const FormUrlEncodedRequestBody({
    this.fields = const {},
  });
}

final class MultipartRequestBody extends RequestBody<Never> {
  /// Plain text fields sent alongside any file parts.
  final List<MultipartField> fields;

  /// File parts to upload.
  final List<MultipartFilePart> files;

  const MultipartRequestBody({
    this.fields = const [],
    this.files = const [],
  });
}

final class RawRequestBody extends RequestBody<Never> {
  /// Raw bytes sent without structural encoding such as JSON or multipart.
  final List<int> bytes;

  const RawRequestBody(this.bytes);
}

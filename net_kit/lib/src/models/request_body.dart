import 'package:net_kit/src/models/multipart_file_part.dart';
import 'package:net_kit/src/models/raw_data.dart';

sealed class RequestBody {
  const RequestBody();
}

final class RawBody extends RequestBody {
  final RawData data;
  final String contentType;

  const RawBody(this.data, {required this.contentType});
}

final class JsonBody extends RequestBody {
  final Map<String, dynamic> data;

  const JsonBody(this.data);
}

final class FormUrlEncodedBody extends RequestBody {
  final Map<String, String> fields;

  const FormUrlEncodedBody({
    this.fields = const {},
  });
}

final class MultipartBody extends RequestBody {
  final Map<String, String> fields;
  final List<MultipartFilePart> files;

  const MultipartBody({
    this.fields = const {},
    this.files = const [],
  });
}

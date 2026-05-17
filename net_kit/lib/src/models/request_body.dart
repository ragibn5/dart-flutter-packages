import 'package:net_kit/src/contracts/mappable.dart';
import 'package:net_kit/src/models/multipart_file_part.dart';
import 'package:net_kit/src/models/raw_data.dart';

sealed class RequestBody implements Mappable {
  final String contentType;

  const RequestBody({required this.contentType});
}

final class RawBody extends RequestBody {
  final RawData data;

  const RawBody(this.data, {required super.contentType});

  @override
  Map<String, dynamic> toMap() {
    return {'data': data.toMap()};
  }
}

final class JsonBody extends RequestBody {
  final Map<String, dynamic> data;

  const JsonBody(this.data, {super.contentType = 'application/json'});

  @override
  Map<String, dynamic> toMap() {
    return {'data': data};
  }
}

final class FormUrlEncodedBody extends RequestBody {
  final Map<String, String> fields;

  const FormUrlEncodedBody({
    this.fields = const {},
    super.contentType = 'application/x-www-form-urlencoded',
  });

  @override
  Map<String, dynamic> toMap() {
    return {'fields': fields};
  }
}

final class MultipartBody extends RequestBody {
  final Map<String, String> fields;
  final List<MultipartFilePart> files;

  const MultipartBody({
    this.fields = const {},
    this.files = const [],
    super.contentType = 'multipart/form-data',
  });

  @override
  Map<String, dynamic> toMap() {
    return {'fields': fields, 'files': files.map((e) => e.toMap())};
  }
}

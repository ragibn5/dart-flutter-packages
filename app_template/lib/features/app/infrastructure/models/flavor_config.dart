import 'package:equatable/equatable.dart';

class FlavorConfig extends Equatable {
  final String flavor;
  final String baseUrl;
  final String storageBucketUrl;

  const FlavorConfig({
    required this.flavor,
    required this.baseUrl,
    required this.storageBucketUrl,
  });

  @override
  List<Object?> get props => [flavor, baseUrl, storageBucketUrl];
}

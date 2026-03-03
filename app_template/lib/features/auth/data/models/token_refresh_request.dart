import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'token_refresh_request.g.dart';

@JsonSerializable()
class TokenRefreshRequest extends Equatable {
  final String refreshToken;

  const TokenRefreshRequest({required this.refreshToken});

  Map<String, dynamic> toJson() => _$TokenRefreshRequestToJson(this);

  factory TokenRefreshRequest.fromMap(Map<String, dynamic> json) =>
      _$TokenRefreshRequestFromJson(json);

  @override
  List<Object?> get props => [refreshToken];
}

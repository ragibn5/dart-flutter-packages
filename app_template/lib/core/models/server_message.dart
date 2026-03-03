import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'server_message.g.dart';

@JsonSerializable()
class ServerMessage extends Equatable {
  final String code;
  final String? message;

  const ServerMessage({required this.code, this.message});

  Map<String, dynamic> toJson() => _$ServerMessageToJson(this);

  factory ServerMessage.fromJson(Map<String, dynamic> json) =>
      _$ServerMessageFromJson(json);

  @override
  List<Object?> get props => [code, message];
}

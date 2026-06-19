import 'package:equatable/equatable.dart';

class ServerMessage extends Equatable {
  final String code;
  final String? message;

  const ServerMessage({required this.code, this.message});

  @override
  List<Object?> get props => [code, message];

  Map<String, dynamic> toJson() {
    return {'code': code, 'message': message};
  }

  factory ServerMessage.fromJson(Map<String, dynamic> map) {
    return ServerMessage(
      code: map['code'] as String,
      message: map['message'] as String?,
    );
  }
}

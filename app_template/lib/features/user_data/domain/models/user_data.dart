import 'package:equatable/equatable.dart';

class UserData extends Equatable {
  final String id;
  final String name;

  const UserData({required this.id, required this.name});

  @override
  List<Object?> get props => [id, name];
}

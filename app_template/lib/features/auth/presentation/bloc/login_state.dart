part of 'login_bloc.dart';

@immutable
sealed class LoginState extends Equatable {}

final class LoginInitial extends LoginState {
  @override
  List<Object?> get props => [];
}

final class LoginInProgress extends LoginState {
  @override
  List<Object?> get props => [];
}

final class LoginComplete extends LoginState {
  @override
  List<Object?> get props => [];
}

final class LoginError extends LoginState {
  @override
  List<Object?> get props => [];
}

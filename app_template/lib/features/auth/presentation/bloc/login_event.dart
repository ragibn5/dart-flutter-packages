part of 'login_bloc.dart';

@immutable
sealed class LoginEvent {}

final class LoginRequested extends LoginEvent {
  final String username;

  LoginRequested({required this.username});
}

import 'package:equatable/equatable.dart';

sealed class AuthDataRefreshError extends Equatable {}

final class InvalidRefreshToken extends AuthDataRefreshError {
  @override
  List<Object?> get props => [];
}

final class InvalidAuthStateForRefresh extends AuthDataRefreshError {
  @override
  List<Object?> get props => [];
}

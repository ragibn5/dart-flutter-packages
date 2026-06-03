import 'package:base_auth_interceptor/base_auth_interceptor.dart';
import 'package:equatable/equatable.dart';

class AuthData extends Equatable implements BaseAuthData {
  final String userId;

  @override
  final String accessToken;

  @override
  final String refreshToken;

  final DateTime accessTokenExpiry;

  final DateTime refreshTokenExpiry;

  const AuthData({
    required this.userId,
    required this.accessToken,
    required this.refreshToken,
    required this.accessTokenExpiry,
    required this.refreshTokenExpiry,
  });

  @override
  List<Object?> get props => [
    userId,
    accessToken,
    refreshToken,
    accessTokenExpiry,
    refreshTokenExpiry,
  ];
}

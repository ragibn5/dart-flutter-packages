import 'package:app_template/core/models/base_auth_data.dart';
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

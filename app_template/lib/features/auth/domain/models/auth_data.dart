import 'package:equatable/equatable.dart';

class AuthData extends Equatable {
  final String userId;
  final String accessToken;
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

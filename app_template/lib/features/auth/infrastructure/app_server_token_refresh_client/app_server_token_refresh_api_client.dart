import 'package:app_template/core/infrastructure/network/clients/feature_api_client.dart';
import 'package:app_template/core/models/server_message.dart';
import 'package:app_template/features/auth/data/models/auth_data_dto.dart';
import 'package:app_template/features/auth/data/models/token_refresh_request.dart';

typedef AppServerTokenRefreshApiClient =
    FeatureApiClient<TokenRefreshRequest, AuthDataDTO, ServerMessage>;

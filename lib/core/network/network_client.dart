import 'package:dio/dio.dart';
import '../constants/app_constants.dart';
import '../../features/auth/data/datasources/auth_local_data_source.dart';

class NetworkClient {
  late final Dio _dio;
  final AuthLocalDataSource? authLocalDataSource;

  NetworkClient({this.authLocalDataSource}) {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.baseUrl,
        connectTimeout: const Duration(
          milliseconds: AppConstants.connectionTimeout,
        ),
        receiveTimeout: const Duration(
          milliseconds: AppConstants.receiveTimeout,
        ),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _setupInterceptors();
  }

  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Add auth token if available
          if (authLocalDataSource != null) {
            final token = await authLocalDataSource!.getAccessToken();
            if (token != null) {
              options.headers['Authorization'] = 'Bearer $token';
            }
          }
          handler.next(options);
        },
        onResponse: (response, handler) {
          handler.next(response);
        },
        onError: (error, handler) async {
          // Handle 401 errors by attempting token refresh
          if (error.response?.statusCode == 401 &&
              authLocalDataSource != null) {
            final refreshToken = await authLocalDataSource!.getRefreshToken();
            if (refreshToken != null) {
              try {
                // Attempt to refresh token
                final response = await _dio.post(
                  '/auth/refresh',
                  data: {'refresh_token': refreshToken},
                  options: Options(
                    headers: {},
                  ), // Remove auth header for refresh request
                );

                if (response.statusCode == 200) {
                  // Save new tokens
                  final newAccessToken = response.data['access_token'];
                  final newRefreshToken = response.data['refresh_token'];

                  await authLocalDataSource!.setAccessToken(newAccessToken);
                  await authLocalDataSource!.setRefreshToken(newRefreshToken);

                  // Retry original request with new token
                  error.requestOptions.headers['Authorization'] =
                      'Bearer $newAccessToken';
                  final retryResponse = await _dio.fetch(error.requestOptions);
                  return handler.resolve(retryResponse);
                }
              } catch (e) {
                // Token refresh failed, clear tokens
                await authLocalDataSource!.clearCache();
              }
            }
          }
          handler.next(error);
        },
      ),
    );
  }

  Dio get dio => _dio;
}

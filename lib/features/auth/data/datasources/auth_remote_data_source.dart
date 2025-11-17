import 'dart:developer'; // Added for logging
import 'package:dio/dio.dart';
import '../../../../core/errors/exceptions.dart';

abstract class AuthRemoteDataSource {
  Future<Map<String, String>> login(String email, String password);
  Future<Map<String, String>> signup(
    String name,
    String email,
    String password,
  );
  Future<Map<String, String>> refresh(String refreshToken);
  Future<Map<String, dynamic>> getCurrentUser(String accessToken);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio dio;

  // Demo/Test account credentials for development
  static const String _demoEmail = 'test@voicely.com';
  static const String _demoPassword = 'password123';
  static const bool _enableDemoAccount = true; // Set to false in production

  AuthRemoteDataSourceImpl({required this.dio});

  @override
  Future<Map<String, String>> login(String email, String password) async {
    // Check for demo account login
    if (_enableDemoAccount &&
        email == _demoEmail &&
        password == _demoPassword) {
      log('Demo account login successful');
      return {
        'access_token':
            'demo_access_token_${DateTime.now().millisecondsSinceEpoch}',
        'refresh_token':
            'demo_refresh_token_${DateTime.now().millisecondsSinceEpoch}',
        'token_type': 'Bearer',
      };
    }

    try {
      log('Attempting login with email: $email'); // Log request details
      final response = await dio.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );

      log('Login response: ${response.data}'); // Log response details

      if (response.statusCode == 200) {
        return {
          'access_token': response.data['access_token'],
          'refresh_token': response.data['refresh_token'],
          'token_type': response.data['token_type'],
        };
      } else {
        throw ServerException('Failed to login: ${response.statusMessage}');
      }
    } catch (e) {
      if (e is DioException && e.response != null) {
        log('DioException response: ${e.response!.data}'); // Log error response
        if (e.response!.statusCode == 401) {
          throw UnauthorizedException('Invalid credentials');
        } else if (e.response!.statusCode == 400) {
          throw ValidationException(
            e.response!.data['detail'] ?? 'Validation error',
          );
        }
      }
      log('Login failed: ${e.toString()}'); // Log general error
      throw ServerException('Login failed: ${e.toString()}');
    }
  }

  @override
  Future<Map<String, String>> signup(
    String name,
    String email,
    String password,
  ) async {
    try {
      final response = await dio.post(
        '/auth/register', // Updated endpoint to match AppConstants
        data: {'name': name, 'email': email, 'password': password},
      );

      if (response.statusCode == 201) {
        return {
          'access_token': response.data['access_token'],
          'refresh_token': response.data['refresh_token'],
          'token_type': response.data['token_type'],
        };
      } else {
        throw ServerException('Failed to sign up: ${response.statusMessage}');
      }
    } catch (e) {
      if (e is DioException && e.response != null) {
        if (e.response!.statusCode == 400) {
          throw ValidationException(
            e.response!.data['detail'] ?? 'Validation error',
          );
        }
      }
      throw ServerException('Signup failed: ${e.toString()}');
    }
  }

  @override
  Future<Map<String, String>> refresh(String refreshToken) async {
    try {
      final response = await dio.post(
        '/auth/refresh',
        data: {'refresh_token': refreshToken},
      );

      if (response.statusCode == 200) {
        return {
          'access_token': response.data['access_token'],
          'refresh_token': response.data['refresh_token'],
          'token_type': response.data['token_type'],
        };
      } else {
        throw ServerException(
          'Failed to refresh token: ${response.statusMessage}',
        );
      }
    } catch (e) {
      if (e is DioException && e.response != null) {
        if (e.response!.statusCode == 400) {
          throw ValidationException(
            e.response!.data['detail'] ?? 'Validation error',
          );
        }
      }
      throw ServerException('Token refresh failed: ${e.toString()}');
    }
  }

  @override
  Future<Map<String, dynamic>> getCurrentUser(String accessToken) async {
    // Check for demo account token
    if (_enableDemoAccount && accessToken.startsWith('demo_access_token_')) {
      log('Returning demo user data');
      return {
        'id': 'demo_user_001',
        'name': 'Demo User',
        'email': _demoEmail,
        'created_at': DateTime.now().toIso8601String(),
      };
    }

    try {
      final response = await dio.get(
        '/auth/me',
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw ServerException(
          'Failed to fetch user info: ${response.statusMessage}',
        );
      }
    } catch (e) {
      if (e is DioException && e.response != null) {
        if (e.response!.statusCode == 401) {
          throw UnauthorizedException('Invalid or expired token');
        }
      }
      throw ServerException('Fetching user info failed: ${e.toString()}');
    }
  }
}

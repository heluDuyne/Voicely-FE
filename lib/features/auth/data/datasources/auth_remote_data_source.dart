import 'package:dio/dio.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login(String email, String password);
  Future<UserModel> signup(String name, String email, String password);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio dio;

  AuthRemoteDataSourceImpl({required this.dio});

  // Mock users for testing
  final List<Map<String, dynamic>> _mockUsers = [
    {
      'id': '1',
      'name': 'John Doe',
      'email': 'john@example.com',
      'password': 'password123',
      'avatar': null,
      'created_at': '2024-01-01T00:00:00Z',
    },
    {
      'id': '2',
      'name': 'Jane Smith',
      'email': 'jane@example.com',
      'password': 'password123',
      'avatar': null,
      'created_at': '2024-01-01T00:00:00Z',
    },
    {
      'id': '3',
      'name': 'Test User',
      'email': 'test@test.com',
      'password': '123456',
      'avatar': null,
      'created_at': '2024-01-01T00:00:00Z',
    },
  ];

  @override
  Future<UserModel> login(String email, String password) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    try {
      // Find user by email
      final user = _mockUsers.firstWhere(
        (user) => user['email'] == email,
        orElse: () => throw UnauthorizedException('User not found'),
      );

      // Check password
      if (user['password'] != password) {
        throw UnauthorizedException('Invalid credentials');
      }

      // Remove password from response
      final userData = Map<String, dynamic>.from(user);
      userData.remove('password');

      return UserModel.fromJson(userData);
    } catch (e) {
      if (e is UnauthorizedException) {
        rethrow;
      }
      throw ServerException('Login failed: ${e.toString()}');
    }
  }

  @override
  Future<UserModel> signup(String name, String email, String password) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    try {
      // Check if user already exists
      final existingUser = _mockUsers.where((user) => user['email'] == email);
      if (existingUser.isNotEmpty) {
        throw ValidationException('User with this email already exists');
      }

      // Create new user
      final newUser = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'name': name,
        'email': email,
        'avatar': null,
        'created_at': DateTime.now().toIso8601String(),
      };

      // Add to mock database
      _mockUsers.add({...newUser, 'password': password});

      return UserModel.fromJson(newUser);
    } catch (e) {
      if (e is ValidationException) {
        rethrow;
      }
      throw ServerException('Signup failed: ${e.toString()}');
    }
  }
}

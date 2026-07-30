import 'package:dio/dio.dart';

import '../core/constants/api_constants.dart';
import '../core/errors/exceptions.dart';
import '../models/user_model.dart';
import 'api_service.dart';
import 'storage_service.dart';

class AuthService {
  final ApiService _apiService;
  final StorageService _storageService;

  AuthService(this._apiService, this._storageService);

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _apiService.post(
        ApiConstants.login,
        data: {'email': email, 'password': password},
      );

      final data = response.data as Map<String, dynamic>;
      final token = data['token'] as String?;
      final userData = data['user'] as Map<String, dynamic>?;

      if (token == null || userData == null) {
        throw const AppException('Invalid response from server');
      }

      final user = UserModel.fromJson(userData);
      await _storageService.saveToken(token);
      await _storageService.saveUser(user);

      return {'token': token, 'user': user};
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    String? phone,
    String role = 'patient',
  }) async {
    try {
      final response = await _apiService.post(
        ApiConstants.register,
        data: {
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': password,
          if (phone != null && phone.isNotEmpty) 'phone': phone,
          'role': role,
        },
      );

      final data = response.data as Map<String, dynamic>;
      final token = data['token'] as String?;
      final userData = data['user'] as Map<String, dynamic>?;

      if (token == null || userData == null) {
        throw const AppException('Invalid response from server');
      }

      final user = UserModel.fromJson(userData);
      await _storageService.saveToken(token);
      await _storageService.saveUser(user);

      return {'token': token, 'user': user};
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<void> logout() async {
    try {
      await _apiService.post(ApiConstants.logout);
    } catch (_) {
      // Ignore errors on logout
    } finally {
      await _storageService.clearAll();
    }
  }

  Future<UserModel> getProfile() async {
    try {
      final response = await _apiService.get(ApiConstants.profile);
      final data = response.data as Map<String, dynamic>;
      final userData = data['user'] as Map<String, dynamic>? ?? data;
      return UserModel.fromJson(userData);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<UserModel> updateProfile({
    String? name,
    String? phone,
    String? profileImage,
  }) async {
    try {
      final response = await _apiService.put(
        ApiConstants.updateProfile,
        data: {
          if (name != null) 'name': name,
          if (phone != null) 'phone': phone,
          if (profileImage != null) 'profile_image': profileImage,
        },
      );
      final data = response.data as Map<String, dynamic>;
      final userData = data['user'] as Map<String, dynamic>? ?? data;
      final user = UserModel.fromJson(userData);
      await _storageService.saveUser(user);
      return user;
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }
}

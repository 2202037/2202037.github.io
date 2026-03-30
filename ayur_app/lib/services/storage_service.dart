import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

import '../core/constants/app_constants.dart';
import '../models/user_model.dart';

class StorageService {
  static const _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  // Token management
  Future<void> saveToken(String token) async {
    await _secureStorage.write(key: AppConstants.tokenKey, value: token);
  }

  Future<String?> getToken() async {
    return _secureStorage.read(key: AppConstants.tokenKey);
  }

  Future<void> clearToken() async {
    await _secureStorage.delete(key: AppConstants.tokenKey);
  }

  // User management
  Future<void> saveUser(UserModel user) async {
    final userJson = jsonEncode(user.toJson());
    await _secureStorage.write(key: AppConstants.userKey, value: userJson);
  }

  Future<UserModel?> getUser() async {
    final userJson = await _secureStorage.read(key: AppConstants.userKey);
    if (userJson == null) return null;
    try {
      final map = jsonDecode(userJson) as Map<String, dynamic>;
      return UserModel.fromJson(map);
    } catch (_) {
      return null;
    }
  }

  Future<void> clearUser() async {
    await _secureStorage.delete(key: AppConstants.userKey);
  }

  // Clear all
  Future<void> clearAll() async {
    await _secureStorage.deleteAll();
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}

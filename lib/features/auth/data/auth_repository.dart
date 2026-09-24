import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_response.dart';
import '../../../core/storage/secure_storage.dart';
import 'models/user_model.dart';

class AuthRepository {
  final ApiClient client;
  final StorageService storage;

  AuthRepository({required this.client, required this.storage});

  Future<ApiResponse<UserModel>> login({
    required String identifier,
    required String password,
  }) async {
    final response = await client.post(
      ApiEndpoints.login,
      data: {
        'identifier': identifier.trim(),
        'password': password,
      },
    );

    if (response.isSuccess && response.data != null) {
      final data = response.data;
      final token = data['access_token']?.toString();
      if (token != null) {
        await storage.saveToken(token);
      }

      final userData = data['user'] ?? data;
      final user = UserModel.fromJson(userData);
      await storage.saveUserId(user.id);
      return ApiResponse.success(user, response.statusCode);
    }

    return ApiResponse.error(response.message ?? 'Login failed', response.statusCode);
  }

  Future<ApiResponse<UserModel>> register(Map<String, dynamic> registerData) async {
    final response = await client.post(
      ApiEndpoints.register,
      data: registerData,
    );

    if (response.isSuccess && response.data != null) {
      final data = response.data;
      final token = data['access_token']?.toString();
      if (token != null) {
        await storage.saveToken(token);
      }
      final userData = data['user'] ?? data;
      final user = UserModel.fromJson(userData);
      await storage.saveUserId(user.id);

      // Backend /auth/register returns UserOut without token; auto-login to acquire JWT
      if (token == null && registerData['email'] != null && registerData['password'] != null) {
        final loginRes = await login(
          identifier: registerData['email'].toString(),
          password: registerData['password'].toString(),
        );
        if (loginRes.isSuccess) {
          return loginRes;
        }
      }

      return ApiResponse.success(user, response.statusCode);
    }

    return ApiResponse.error(response.message ?? 'Registration failed', response.statusCode);
  }

  Future<ApiResponse<UserModel>> getMe() async {
    final response = await client.get(ApiEndpoints.me);
    if (response.isSuccess && response.data != null) {
      final data = response.data;
      final userData = data['user'] ?? data;
      final user = UserModel.fromJson(userData);
      return ApiResponse.success(user, response.statusCode);
    }
    return ApiResponse.error(response.message ?? 'Failed to fetch user', response.statusCode);
  }

  Future<ApiResponse<UserModel>> updateProfile(Map<String, dynamic> updateData) async {
    final response = await client.patch(
      ApiEndpoints.me,
      data: updateData,
    );

    if (response.isSuccess && response.data != null) {
      final data = response.data;
      final userData = data['user'] ?? data;
      final user = UserModel.fromJson(userData);
      return ApiResponse.success(user, response.statusCode);
    }
    return ApiResponse.error(response.message ?? 'Failed to update profile', response.statusCode);
  }

  Future<ApiResponse<bool>> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    final response = await client.post(
      ApiEndpoints.changePassword,
      data: {
        'old_password': oldPassword,
        'new_password': newPassword,
      },
    );

    if (response.isSuccess) {
      return ApiResponse.success(true, response.statusCode);
    }
    return ApiResponse.error(response.message ?? 'Failed to change password', response.statusCode);
  }

  Future<ApiResponse<bool>> forgotPassword(String email) async {
    final response = await client.post(
      ApiEndpoints.forgotPassword,
      data: {'email': email.trim()},
    );
    if (response.isSuccess) {
      return ApiResponse.success(true, response.statusCode);
    }
    return ApiResponse.error(response.message ?? 'Failed to send reset email', response.statusCode);
  }

  Future<ApiResponse<bool>> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    final response = await client.post(
      ApiEndpoints.resetPassword,
      data: {
        'email': email.trim(),
        'code': code.trim(),
        'new_password': newPassword,
      },
    );
    if (response.isSuccess) {
      return ApiResponse.success(true, response.statusCode);
    }
    return ApiResponse.error(response.message ?? 'Failed to reset password', response.statusCode);
  }

  Future<void> logout() async {
    try {
      await client.post(ApiEndpoints.logout);
    } catch (_) {
      // Ignore network errors on logout
    }
    await storage.clearToken();
  }
}

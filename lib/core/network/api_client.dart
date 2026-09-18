import 'package:dio/dio.dart';
import '../constants/api_endpoints.dart';
import '../storage/secure_storage.dart';
import 'api_response.dart';
import 'auth_interceptor.dart';

class ApiClient {
  late final Dio dio;
  final StorageService storage;

  ApiClient({required this.storage, void Function()? onUnauthorized}) {
    final customUrl = storage.getCustomBaseUrl();
    final effectiveBaseUrl = (customUrl != null && customUrl.isNotEmpty)
        ? customUrl
        : ApiEndpoints.baseUrl;

    dio = Dio(
      BaseOptions(
        baseUrl: effectiveBaseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.add(
      AuthInterceptor(
        storage: storage,
        onUnauthorized: onUnauthorized,
      ),
    );
  }

  void updateBaseUrl(String newUrl) {
    dio.options.baseUrl = newUrl;
    ApiEndpoints.baseUrl = newUrl;
  }

  String _formatError(dynamic error) {
    if (error is DioException) {
      if (error.response != null && error.response?.data != null) {
        final data = error.response!.data;
        if (data is Map) {
          if (data.containsKey('detail')) {
            final detail = data['detail'];
            if (detail is String) return detail;
            if (detail is List) {
              return detail.map((e) => e is Map ? (e['msg'] ?? e.toString()) : e.toString()).join('\n');
            }
          }
          if (data.containsKey('message')) {
            return data['message'].toString();
          }
          if (data.containsKey('errors') && data['errors'] is List) {
            return (data['errors'] as List).join('\n');
          }
        }
        return error.response?.statusMessage ?? 'Server Error (${error.response?.statusCode})';
      }

      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return 'Network request timed out. Please check your internet connection.';
        case DioExceptionType.connectionError:
          return 'Unable to reach the server. Please verify your connection.';
        default:
          return error.message ?? 'An unexpected network error occurred.';
      }
    }
    return error.toString();
  }

  Future<ApiResponse<dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await dio.get(path, queryParameters: queryParameters);
      return ApiResponse.success(response.data, response.statusCode);
    } catch (e) {
      final statusCode = e is DioException ? e.response?.statusCode : null;
      return ApiResponse.error(_formatError(e), statusCode);
    }
  }

  Future<ApiResponse<dynamic>> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await dio.post(path, data: data, queryParameters: queryParameters);
      return ApiResponse.success(response.data, response.statusCode);
    } catch (e) {
      final statusCode = e is DioException ? e.response?.statusCode : null;
      return ApiResponse.error(_formatError(e), statusCode);
    }
  }

  Future<ApiResponse<dynamic>> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await dio.put(path, data: data, queryParameters: queryParameters);
      return ApiResponse.success(response.data, response.statusCode);
    } catch (e) {
      final statusCode = e is DioException ? e.response?.statusCode : null;
      return ApiResponse.error(_formatError(e), statusCode);
    }
  }

  Future<ApiResponse<dynamic>> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await dio.patch(path, data: data, queryParameters: queryParameters);
      return ApiResponse.success(response.data, response.statusCode);
    } catch (e) {
      final statusCode = e is DioException ? e.response?.statusCode : null;
      return ApiResponse.error(_formatError(e), statusCode);
    }
  }

  Future<ApiResponse<dynamic>> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await dio.delete(path, data: data, queryParameters: queryParameters);
      return ApiResponse.success(response.data, response.statusCode);
    } catch (e) {
      final statusCode = e is DioException ? e.response?.statusCode : null;
      return ApiResponse.error(_formatError(e), statusCode);
    }
  }
}

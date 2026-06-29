import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiClient {
  final Dio dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  static const String baseUrl = 'http://localhost:8000/api/v1';

  ApiClient() : dio = Dio(BaseOptions(baseUrl: baseUrl, connectTimeout: const Duration(seconds: 10))) {
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _getStoredToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (DioException e, handler) async {
        if (e.response?.statusCode == 401) {
          final success = await _refreshToken();
          if (success) {
            final requestOptions = e.requestOptions;
            final token = await _getStoredToken();
            requestOptions.headers['Authorization'] = 'Bearer $token';
            final response = await dio.fetch(requestOptions);
            return handler.resolve(response);
          }
        }
        return handler.next(e);
      },
    ));
  }

  Future<String?> _getStoredToken() async => await _storage.read(key: 'access_token');

  Future<void> setTokens(String auth, String refresh) async {
    await _storage.write(key: 'access_token', value: auth);
    await _storage.write(key: 'refresh_token', value: refresh);
  }

  Future<void> clearTokens() async {
    await _storage.delete(key: 'access_token');
    await _storage.delete(key: 'refresh_token');
  }

  Future<bool> _refreshToken() async {
    final refreshTokenStr = await _storage.read(key: 'refresh_token');
    if (refreshTokenStr == null) return false;
    try {
      final response = await Dio().post(
        '$baseUrl/auth/refresh',
        data: {'refresh_token': refreshTokenStr},
      );
      if (response.statusCode == 200) {
        final auth = response.data['access_token'];
        final refresh = response.data['refresh_token'];
        await setTokens(auth, refresh);
        return true;
      }
    } catch (e) {
      await clearTokens();
    }
    return false;
  }
}

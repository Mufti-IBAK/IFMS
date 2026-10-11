import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../di/service_locator.dart';
import 'notification_service.dart';

class ApiClient {
  final Dio dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  static const String baseUrl = 'https://mhrhlkgouekkrqncewbb.supabase.co/rest/v1/';
  static const String authBaseUrl = 'https://mhrhlkgouekkrqncewbb.supabase.co/auth/v1/';
  static const String anonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1ocmhsa2dvdWVra3JxbmNld2JiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODI3MzgxMzAsImV4cCI6MjA5ODMxNDEzMH0.wezUbIxZa2GXsCiYqTZwrpWUbvJzYy2F1vRv8mcF6Bo';
  static const String googleWebClientId = '10036986821-ilndripmt502ni879ncvtc32bf468ive.apps.googleusercontent.com';

  final Dio _authDio = Dio(BaseOptions(
    baseUrl: authBaseUrl,
    connectTimeout: const Duration(seconds: 15),
    headers: {
      'apikey': anonKey,
      'Content-Type': 'application/json',
    },
  ));

  ApiClient() : dio = Dio(BaseOptions(baseUrl: baseUrl, connectTimeout: const Duration(seconds: 10))) {
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        options.headers['apikey'] = anonKey;
        final token = await _storage.read(key: 'access_token');
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        } else {
          options.headers['Authorization'] = 'Bearer $anonKey';
        }
        if (options.method == 'POST') {
           options.headers['Prefer'] = 'return=representation';
           options.headers['Accept'] = 'application/vnd.pgrst.object+json';
        } else if (options.method == 'PATCH') {
           options.headers['Prefer'] = 'return=representation';
        }

        // Rewrite paths for Supabase
        String path = options.path;
        
        // Strip /api/v1 prefix if present
        if (path.startsWith('/api/v1')) {
          path = path.replaceFirst('/api/v1', '');
        }

        // Custom path parameter extracts for POST requests before generic matches
        if (options.method == 'POST' && options.data is Map<String, dynamic>) {
          final data = options.data as Map<String, dynamic>;
          
          if (path.startsWith('/animals/')) {
            final segments = path.split('/');
            if (segments.length > 3 && segments[3] == 'events') {
              final animalId = segments[2];
              path = '/animal_events';
              data['animal_id'] = animalId;
            }
          } else if (path.startsWith('/poultry/batch/')) {
            final segments = path.split('/');
            if (segments.length > 3 && (segments[3] == 'event' || segments[3] == 'logs')) {
              final batchId = segments[2];
              path = '/poultry_events';
              data['batch_id'] = batchId;
            }
          } else if (path.startsWith('/hatchery/batch/')) {
            final segments = path.split('/');
            if (segments.length > 3 && segments[3] == 'event') {
              final batchId = segments[2];
              path = '/hatchery_events';
              data['batch_id'] = batchId;
            }
          }
        }

        bool isUuid(String s) {
          return s.length == 36 && s.contains('-');
        }

        if (options.method == 'PATCH' || options.method == 'DELETE' || options.method == 'PUT') {
          final segments = path.split('/');
          if (segments.length > 2) {
            String id;
            String? action;
            if (segments.length > 3 && !isUuid(segments.last) && isUuid(segments[segments.length - 2])) {
              id = segments[segments.length - 2];
              action = segments.last;
              path = segments.sublist(0, segments.length - 2).join('/');
            } else {
              id = segments.last;
              path = segments.sublist(0, segments.length - 1).join('/');
            }
            options.queryParameters['id'] = 'eq.$id';

            if (action == 'reconcile') {
              options.data = {'is_reconciled': true};
            } else if (action == 'resolve') {
              options.data ??= {};
              if (options.data is Map<String, dynamic>) {
                (options.data as Map<String, dynamic>)['is_resolved'] = true;
                (options.data as Map<String, dynamic>)['resolved_at'] = DateTime.now().toIso8601String();
              }
            }
          }
        }
        
        if (path.startsWith('/animals')) {
           path = path.replaceAll('/animals', '/animals'); // no change
        } else if (path.startsWith('/breeding')) {
           path = '/breeding_events';
        } else if (path.startsWith('/dairy/milk-record') || path.startsWith('/dairy/milk_records')) {
           path = '/milk_records';
        } else if (path.startsWith('/finance/transaction')) {
           path = '/transactions';
        } else if (path.startsWith('/inventory/items')) {
           path = '/feed_items';
        } else if (path.startsWith('/inventory/log')) {
           path = '/inventory_logs';
        } else if (path.startsWith('/poultry/batch')) {
           if (path.contains('event') || path.contains('logs')) {
             path = '/poultry_events';
           } else {
             path = '/poultry_batches';
           }
        } else if (path.startsWith('/hatchery/batch')) {
           if (path.contains('event')) {
             path = '/hatchery_events';
           } else {
             path = '/hatchery_batches';
           }
        } else if (path.startsWith('/staff/queries')) {
           path = '/staff_queries';
        } else if (path.startsWith('/staff')) {
           path = '/staff';
        } else if (path.startsWith('/tasks')) {
           path = '/tasks';
        } else if (path.startsWith('/alerts')) {
           path = '/alerts';
        } else if (path.startsWith('/yoghurt/batches') || path.startsWith('/yoghurt_production_batches')) {
           path = '/yoghurt_production_batches';
        } else if (path.startsWith('/yoghurt/sales') || path.startsWith('/yoghurt_sales')) {
           path = '/yoghurt_sales';
        } else if (path.startsWith('/yoghurt/returns') || path.startsWith('/yoghurt_returns')) {
           path = '/yoghurt_returns';
        } else if (path.startsWith('/yoghurt/expenses') || path.startsWith('/yoghurt_expenses')) {
           path = '/yoghurt_expenses';
        }

        // Let Supabase handle created_by/logged_by via DEFAULT auth.uid()

        // Remove duplicate /rest/v1 if it already exists
        if (!path.startsWith('/rest/v1')) {
          if (path.startsWith('/')) {
            options.path = path.substring(1);
          } else {
            options.path = path;
          }
        }

        return handler.next(options);
      },
      onResponse: (response, handler) {
        final method = response.requestOptions.method.toUpperCase();
        
        if (method == 'PATCH') {
          if (response.data is List && (response.data as List).isEmpty) {
            return handler.reject(DioException(
              requestOptions: response.requestOptions,
              response: Response(
                requestOptions: response.requestOptions,
                statusCode: 404,
                data: {'message': 'Record not found on server. Please refresh your data.'},
              ),
              type: DioExceptionType.badResponse,
            ));
          }
        }

        if ((method == 'POST' || method == 'PATCH' || method == 'DELETE') &&
            (response.statusCode == 200 || response.statusCode == 201)) {
          
          final pathParts = response.requestOptions.path.split('/');
          final rawTarget = pathParts.isNotEmpty ? pathParts.last.toUpperCase() : 'DATA';

          // Human friendly translations
          String targetName = 'Operations Database';
          if (rawTarget.contains('STAFF')) {
            targetName = 'Staff Registry';
          } else if (rawTarget.contains('ANIMAL')) {
            targetName = 'Livestock Portfolio';
          } else if (rawTarget.contains('MILK') || rawTarget.contains('RECORD')) {
            targetName = 'Milk Records';
          } else if (rawTarget.contains('TRANSACTION')) {
            targetName = 'Financial Ledger';
          } else if (rawTarget.contains('FEED') || rawTarget.contains('ITEM')) {
            targetName = 'Feed Stocks';
          } else if (rawTarget.contains('POULTRY')) {
            targetName = 'Poultry Flocks';
          } else if (rawTarget.contains('HATCHERY')) {
            targetName = 'Avian Incubation';
          } else if (rawTarget.contains('TASK')) {
            targetName = 'Task Logs';
          } else if (rawTarget.contains('ALERT')) {
            targetName = 'System Alerts';
          }

          String actionVerb = 'updated';
          if (method == 'POST') {
            actionVerb = 'added to';
          } else if (method == 'DELETE') {
            actionVerb = 'removed from';
          }

          sl<NotificationService>().showLocalNotification(
            'Sync Successful',
            'Successfully $actionVerb $targetName.',
          );
        }
        return handler.next(response);
      },
      onError: (DioException e, handler) async {
        if (e.type == DioExceptionType.connectionTimeout || 
            e.type == DioExceptionType.sendTimeout || 
            e.type == DioExceptionType.receiveTimeout || 
            e.type == DioExceptionType.connectionError) {
          
          final friendlyError = DioException(
            requestOptions: e.requestOptions,
            type: e.type,
            error: e.error,
            response: Response(
              requestOptions: e.requestOptions,
              statusCode: 503,
              data: {'message': 'No internet connection. Please verify your network and try again.'},
            ),
          );
          return handler.next(friendlyError);
        }
        return handler.next(e);
      },
    ));
  }

  Future<void> setTokens(String auth, String refresh) async {
    await _storage.write(key: 'access_token', value: auth);
    await _storage.write(key: 'refresh_token', value: refresh);
  }

  Future<void> clearTokens() async {
    await _storage.delete(key: 'access_token');
    await _storage.delete(key: 'refresh_token');
    await _storage.delete(key: 'auth_user_json');
  }

  Future<bool> hasValidSession() async {
    final token = await _storage.read(key: 'access_token');
    return token != null && token.isNotEmpty;
  }

  Future<Map<String, dynamic>?> getStoredUser() async {
    final userStr = await _storage.read(key: 'auth_user_json');
    if (userStr != null) {
      try {
        return jsonDecode(userStr) as Map<String, dynamic>;
      } catch (_) {}
    }
    return null;
  }

  /// Sign in with Email and Password via Supabase Auth
  Future<Map<String, dynamic>> signInWithEmailPassword(String email, String password) async {
    try {
      final response = await _authDio.post(
        'token',
        queryParameters: {'grant_type': 'password'},
        data: {
          'email': email.trim(),
          'password': password,
        },
      );
      final data = response.data as Map<String, dynamic>;
      final accessToken = data['access_token'] as String?;
      final refreshToken = data['refresh_token'] as String?;
      if (accessToken != null && refreshToken != null) {
        await setTokens(accessToken, refreshToken);
        if (data['user'] != null) {
          await _storage.write(key: 'auth_user_json', value: jsonEncode(data['user']));
        }
      }
      return data;
    } on DioException catch (e) {
      final msg = e.response?.data?['error_description'] ??
          e.response?.data?['msg'] ??
          e.response?.data?['message'] ??
          e.message ??
          'Email/Password sign-in failed.';
      throw Exception(msg);
    }
  }

  /// Register new user with Email and Password via Supabase Auth
  Future<Map<String, dynamic>> signUpWithEmailPassword(
    String email,
    String password, {
    String? fullName,
    String? phone,
  }) async {
    try {
      final response = await _authDio.post(
        'signup',
        data: {
          'email': email.trim(),
          'password': password,
          'data': {
            if (fullName != null && fullName.isNotEmpty) 'full_name': fullName.trim(),
            if (phone != null && phone.isNotEmpty) 'phone': phone.trim(),
          },
        },
      );
      final data = response.data as Map<String, dynamic>;
      final accessToken = data['access_token'] as String?;
      final refreshToken = data['refresh_token'] as String?;
      if (accessToken != null && refreshToken != null) {
        await setTokens(accessToken, refreshToken);
      }
      if (data['user'] != null) {
        await _storage.write(key: 'auth_user_json', value: jsonEncode(data['user']));
      }
      return data;
    } on DioException catch (e) {
      final msg = e.response?.data?['error_description'] ??
          e.response?.data?['msg'] ??
          e.response?.data?['message'] ??
          e.message ??
          'Registration failed.';
      throw Exception(msg);
    }
  }

  /// Sign in using Google OAuth via GoogleSignIn -> Supabase token exchange
  Future<Map<String, dynamic>> signInWithGoogle() async {
    try {
      final googleSignIn = GoogleSignIn(
        serverClientId: googleWebClientId,
        scopes: ['email', 'profile'],
      );

      // Clean existing Google session to ensure fresh prompt
      try {
        await googleSignIn.signOut();
      } catch (_) {}

      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        throw Exception('Google sign-in was cancelled');
      }

      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;
      if (idToken == null || idToken.isEmpty) {
        throw Exception('Failed to obtain Google ID token. Please check Google Play Services.');
      }

      final response = await _authDio.post(
        'token',
        queryParameters: {'grant_type': 'id_token'},
        data: {
          'provider': 'google',
          'id_token': idToken,
          'client_id': googleWebClientId,
        },
      );

      final data = response.data as Map<String, dynamic>;
      final accessToken = data['access_token'] as String?;
      final refreshToken = data['refresh_token'] as String?;
      if (accessToken != null && refreshToken != null) {
        await setTokens(accessToken, refreshToken);
        if (data['user'] != null) {
          await _storage.write(key: 'auth_user_json', value: jsonEncode(data['user']));
        }
      }
      return data;
    } on DioException catch (e) {
      final msg = e.response?.data?['error_description'] ??
          e.response?.data?['msg'] ??
          e.response?.data?['message'] ??
          e.message ??
          'Google authentication failed.';
      throw Exception(msg);
    }
  }

  /// Refresh existing session
  Future<bool> refreshSession() async {
    try {
      final refreshToken = await _storage.read(key: 'refresh_token');
      if (refreshToken == null || refreshToken.isEmpty) return false;
      final response = await _authDio.post(
        'token',
        queryParameters: {'grant_type': 'refresh_token'},
        data: {'refresh_token': refreshToken},
      );
      final data = response.data as Map<String, dynamic>;
      final newAccessToken = data['access_token'] as String?;
      final newRefreshToken = data['refresh_token'] as String?;
      if (newAccessToken != null && newRefreshToken != null) {
        await setTokens(newAccessToken, newRefreshToken);
        return true;
      }
    } catch (_) {}
    return false;
  }

  /// Sign out completely from Supabase and Google
  Future<void> signOut() async {
    try {
      final token = await _storage.read(key: 'access_token');
      if (token != null && token.isNotEmpty) {
        await _authDio.post(
          'logout',
          options: Options(headers: {'Authorization': 'Bearer $token'}),
        );
      }
    } catch (_) {}
    try {
      final googleSignIn = GoogleSignIn();
      if (await googleSignIn.isSignedIn()) {
        await googleSignIn.signOut();
      }
    } catch (_) {}
    await clearTokens();
  }

  static bool isNetworkError(Object? e) {
    if (e is! DioException) return false;
    return e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.connectionError ||
        e.error.toString().contains('SocketException') ||
        e.message?.contains('SocketException') == true;
  }
}

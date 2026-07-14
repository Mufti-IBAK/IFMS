import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../di/service_locator.dart';
import 'notification_service.dart';

class ApiClient {
  final Dio dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  static const String baseUrl = 'https://mhrhlkgouekkrqncewbb.supabase.co/rest/v1/';
  static const String anonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1ocmhsa2dvdWVra3JxbmNld2JiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODI3MzgxMzAsImV4cCI6MjA5ODMxNDEzMH0.wezUbIxZa2GXsCiYqTZwrpWUbvJzYy2F1vRv8mcF6Bo';

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
        if (options.method == 'POST' || options.method == 'PATCH') {
           options.headers['Prefer'] = 'return=representation';
           options.headers['Accept'] = 'application/vnd.pgrst.object+json';
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

        if (options.method == 'PATCH' || options.method == 'DELETE') {
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
        if ((method == 'POST' || method == 'PATCH' || method == 'DELETE') &&
            (response.statusCode == 200 || response.statusCode == 201)) {
          
          // Generate human readable path (e.g. /staff -> Staff)
          final pathParts = response.requestOptions.path.split('/');
          final target = pathParts.isNotEmpty ? pathParts.last.toUpperCase() : 'Data';

          sl<NotificationService>().showLocalNotification(
            'Action Successful',
            'Successfully synced $method updates for $target.',
          );
        }
        return handler.next(response);
      },
      onError: (DioException e, handler) async {
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
  }
}

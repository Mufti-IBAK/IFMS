import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/services.dart';
import '../../core/di/service_locator.dart';
import '../../core/sync/sync_manager.dart';
import '../../core/theme/app_colors.dart';
import '../../core/network/api_client.dart';
import 'dart:io';

class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  bool _checkingPermissions = true;
  bool _hasPermission = false;
  bool _hasInternet = false;
  bool _restoring = false;
  String _statusMessage = 'Checking permissions...';
  double? _progress;

  @override
  void initState() {
    super.initState();
    _runDiagnostics();
  }

  Future<void> _runDiagnostics() async {
    setState(() {
      _checkingPermissions = true;
      _statusMessage = 'Checking permissions...';
    });

    // 1. Check storage permissions via MethodChannel
    const platform = MethodChannel('com.namanzo.ifms/permissions');
    try {
      final isGranted = await platform.invokeMethod<bool>('isExternalStorageManager');
      _hasPermission = isGranted ?? false;
    } catch (e) {
      _hasPermission = false;
    }

    if (!_hasPermission) {
      setState(() {
        _checkingPermissions = false;
        _statusMessage = 'File Manager permissions are required to initialize the local database.';
      });
      return;
    }

    // 2. Check internet connection
    setState(() {
      _statusMessage = 'Checking internet connection...';
    });
    bool hasConnection = false;
    String diagInfo = '';
    
    try {
      final connectivity = await Connectivity().checkConnectivity();
      if (!connectivity.contains(ConnectivityResult.none)) {
        hasConnection = true;
      }
    } catch (e) {
      diagInfo += 'Connectivity plugin error: $e. ';
    }

    if (!hasConnection) {
      try {
        final response = await sl<ApiClient>().dio.get('').timeout(const Duration(seconds: 4));
        if (response.statusCode != null) {
          hasConnection = true;
        }
      } catch (e) {
        diagInfo += 'API check failed: $e. ';
      }
    }

    if (!hasConnection) {
      try {
        final lookup = await InternetAddress.lookup('supabase.co').timeout(const Duration(seconds: 4));
        if (lookup.isNotEmpty && lookup.first.rawAddress.isNotEmpty) {
          hasConnection = true;
        }
      } catch (e) {
        diagInfo += 'DNS lookup failed: $e.';
      }
    }

    _hasInternet = hasConnection;

    if (!_hasInternet) {
      setState(() {
        _checkingPermissions = false;
        _statusMessage = 'No internet connection detected.\nDetails: $diagInfo\n\nPlease check your connection or tap proceed offline below.';
      });
      return;
    }

    // 3. Trigger restoration
    _startRestoration();
  }

  Future<void> _requestPermissions() async {
    const platform = MethodChannel('com.namanzo.ifms/permissions');
    try {
      await platform.invokeMethod('requestStoragePermissions');
    } catch (_) {}
    
    // Give user time to return and retry diagnostics
    _runDiagnostics();
  }

  Future<void> _startRestoration() async {
    setState(() {
      _checkingPermissions = false;
      _restoring = true;
      _statusMessage = 'Downloading and populating farm records from cloud storage...';
      _progress = null; // Indeterminate spinner
    });

    try {
      final syncManager = sl<SyncManager>();
      
      // Run the restoration
      await syncManager.restoreFromSupabase();

      if (mounted) {
        // Successfully restored, navigate to home screen
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _restoring = false;
          _statusMessage = 'Restoration failed: $e. Please check connection and try again.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(
                Icons.cloud_download_outlined,
                size: 80,
                color: AppColors.primary,
              ),
              const SizedBox(height: 24),
              const Text(
                'IFMS INITIALIZATION',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                _statusMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 32),
              if (_checkingPermissions || _restoring)
                Center(
                  child: CircularProgressIndicator(
                    value: _progress,
                    color: AppColors.primary,
                  ),
                )
              else ...[
                if (!_hasPermission)
                  ElevatedButton.icon(
                    onPressed: _requestPermissions,
                    icon: const Icon(Icons.security),
                    label: const Text('GRANT STORAGE PERMISSIONS'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.onPrimary,
                    ),
                  )
                else if (!_hasInternet) ...[
                  ElevatedButton.icon(
                    onPressed: _runDiagnostics,
                    icon: const Icon(Icons.wifi),
                    label: const Text('RETRY CONNECTION CHECK'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.onPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/home');
                    },
                    icon: const Icon(Icons.offline_pin_outlined),
                    label: const Text('PROCEED ANYWAY (OFFLINE MODE)'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: AppColors.outline),
                      foregroundColor: AppColors.outline,
                    ),
                  ),
                ]
                else
                  ElevatedButton.icon(
                    onPressed: _startRestoration,
                    icon: const Icon(Icons.refresh),
                    label: const Text('RETRY DATA RESTORE'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.onPrimary,
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

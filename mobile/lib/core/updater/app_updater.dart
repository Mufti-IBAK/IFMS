import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import '../network/api_client.dart';
import 'package:flutter/services.dart';
import '../../app.dart';
import '../theme/app_colors.dart';

/// Tracks whether an update is available — consumed by the AppBar badge.
final ValueNotifier<bool> updateAvailableNotifier = ValueNotifier(false);
Map<String, dynamic>? _pendingUpdateData;

class AppUpdater {
  static const _platform = MethodChannel('com.namanzo.ifms/permissions');

  static Future<void> _openBrowser(String url) async {
    try {
      await _platform.invokeMethod('openBrowser', {'url': url});
    } catch (e) {
      debugPrint('Failed to open browser: $e');
    }
  }

  /// Call on startup (non-blocking). Checks Supabase for a newer version
  /// and sets [updateAvailableNotifier] to true if one is found.
  static void checkForUpdates(BuildContext context, {bool showNoUpdateMessage = false}) {
    _doCheck(context, showNoUpdateMessage: showNoUpdateMessage);
  }

  static bool _isUpdateAvailable(String currentVer, String currentBuildStr, String latestVerWithBuild) {
    final latestParts = latestVerWithBuild.split('+');
    final latestVer = latestParts.first;
    final latestBuildStr = latestParts.length > 1 ? latestParts.last : '0';

    final currentSem = currentVer.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    final latestSem = latestVer.split('.').map((e) => int.tryParse(e) ?? 0).toList();

    while (currentSem.length < 3) {
      currentSem.add(0);
    }
    while (latestSem.length < 3) {
      latestSem.add(0);
    }

    for (int i = 0; i < 3; i++) {
      if (latestSem[i] > currentSem[i]) return true;
      if (currentSem[i] > latestSem[i]) return false;
    }

    final latestBuild = int.tryParse(latestBuildStr) ?? 0;
    int currentBuild = int.tryParse(currentBuildStr) ?? 0;

    // The base build number is 20000 + run_number.
    // Flutter split-per-abi adds 1000, 2000, or 3000 to the versionCode.
    int getRunNumber(int code) {
      int remainder = code % 20000;
      return remainder % 1000;
    }

    final currentRun = getRunNumber(currentBuild);
    final latestRun = getRunNumber(latestBuild);

    return latestRun > currentRun;
  }

  static Future<void> _doCheck(BuildContext context, {bool showNoUpdateMessage = false}) async {
    BuildContext? loadingCtx;
    final activeContext = appNavigatorKey.currentContext ?? context;

    if (showNoUpdateMessage && activeContext.mounted) {
      showDialog(
        context: activeContext,
        barrierDismissible: false,
        builder: (dialogCtx) {
          loadingCtx = dialogCtx;
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            content: const Row(
              children: [
                CircularProgressIndicator(color: AppColors.primary),
                SizedBox(width: 20),
                Text('Checking for updates...', style: TextStyle(fontSize: 14)),
              ],
            ),
          );
        },
      );
    }

    try {
      final packageInfo = await PackageInfo.fromPlatform();

      final updateDio = Dio(BaseOptions(
        baseUrl: ApiClient.baseUrl,
        connectTimeout: const Duration(seconds: 10),
        headers: {
          'apikey': ApiClient.anonKey,
          'Authorization': 'Bearer ${ApiClient.anonKey}',
        },
      ));
      final response = await updateDio.get(
        'system_updates',
        queryParameters: {'order': 'id.desc', 'limit': '1'},
      );

      // Dismiss loading dialog if shown
      if (loadingCtx != null && loadingCtx!.mounted) {
        Navigator.pop(loadingCtx!);
        loadingCtx = null;
      }

      if (response.data == null || (response.data as List).isEmpty) {
        if (showNoUpdateMessage) {
          _showSnack('App is up to date (v${packageInfo.version}+${packageInfo.buildNumber})', Colors.green);
        }
        return;
      }

      final latest = response.data[0] as Map<String, dynamic>;
      final latestVersion = latest['version_number']?.toString() ?? '';

      final isNew = _isUpdateAvailable(
        packageInfo.version,
        packageInfo.buildNumber,
        latestVersion,
      );

      debugPrint('[OTA] Local: v${packageInfo.version}+${packageInfo.buildNumber}, Server: $latestVersion, Update: $isNew');

      if (isNew) {
        _pendingUpdateData = latest;
        updateAvailableNotifier.value = true;
        if (showNoUpdateMessage) {
          _showUpdateDialog(latest);
        }
      } else {
        updateAvailableNotifier.value = false;
        if (showNoUpdateMessage) {
          _showUpToDateDialog(latest, packageInfo.version, packageInfo.buildNumber);
        }
      }
    } catch (e) {
      if (loadingCtx != null && loadingCtx!.mounted) {
        Navigator.pop(loadingCtx!);
        loadingCtx = null;
      }
      debugPrint('Update check failed: $e');
      if (showNoUpdateMessage) {
        _showSnack('Update check failed: $e', Colors.orange);
      }
    }
  }

  /// Call when user taps the update button in drawer or settings.
  static void showUpdateDialog(BuildContext context) {
    if (_pendingUpdateData != null) {
      _showUpdateDialog(_pendingUpdateData!);
    } else {
      checkForUpdates(context, showNoUpdateMessage: true);
    }
  }

  static void _showUpToDateDialog(Map<String, dynamic> data, String currentVer, String currentBuild) {
    final ctx = appNavigatorKey.currentContext;
    if (ctx == null || !ctx.mounted) return;

    final latestVer = data['version_number'] ?? 'Latest';
    final downloadUrl = data['download_url'] as String?;

    showDialog(
      context: ctx,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.check_circle_outline, color: Colors.green),
            SizedBox(width: 8),
            Text('App is Up to Date'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Installed Version: v$currentVer+$currentBuild', style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('Latest Server Build: $latestVer', style: const TextStyle(color: Colors.grey, fontSize: 13)),
            const SizedBox(height: 12),
            const Text('You already have the newest release installed.', style: TextStyle(fontSize: 13)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('CLOSE'),
          ),
          if (downloadUrl != null)
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(dialogCtx);
                _downloadAndInstall(downloadUrl);
              },
              icon: const Icon(Icons.download, size: 16),
              label: const Text('FORCE RE-DOWNLOAD (OTA)', style: TextStyle(fontSize: 11)),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
            ),
        ],
      ),
    );
  }

  static void _showUpdateDialog(Map<String, dynamic> data) {
    final ctx = appNavigatorKey.currentContext;
    if (ctx == null || !ctx.mounted) return;

    final version = data['version_number'] ?? 'New Version';
    final notes = data['release_notes'] ?? 'Performance improvements and bug fixes.';
    final downloadUrl = data['download_url'] as String?;

    if (downloadUrl == null) return;

    showDialog(
      context: ctx,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.system_update_alt, color: Color(0xFF4CAF50)),
            SizedBox(width: 8),
            Text('Update Available'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Version: $version', style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('What\'s new:', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text(notes, style: const TextStyle(fontSize: 13)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('LATER'),
          ),
          TextButton.icon(
            onPressed: () {
              Navigator.pop(dialogCtx);
              _openBrowser(downloadUrl);
            },
            icon: const Icon(Icons.open_in_browser, size: 18),
            label: const Text('DIRECT DOWNLOAD'),
            style: TextButton.styleFrom(foregroundColor: Colors.blue),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(dialogCtx);
              _downloadAndInstall(downloadUrl);
            },
            icon: const Icon(Icons.download, size: 16),
            label: const Text('UPDATE VIA OTA'),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4CAF50), foregroundColor: Colors.white),
          ),
        ],
      ),
    );
  }

  static Future<void> _downloadAndInstall(String url) async {
    final ctx = appNavigatorKey.currentContext;
    if (ctx == null || !ctx.mounted) return;

    final progressNotifier = ValueNotifier<double>(0);
    final statusTextNotifier = ValueNotifier<String>('Starting download...');
    BuildContext? downloadDialogContext;

    showDialog(
      context: ctx,
      barrierDismissible: false,
      builder: (dCtx) {
        downloadDialogContext = dCtx;
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.downloading, color: Color(0xFF4CAF50)),
              SizedBox(width: 8),
              Text('Downloading Update'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ValueListenableBuilder<double>(
                valueListenable: progressNotifier,
                builder: (_, p, __) => Column(
                  children: [
                    LinearProgressIndicator(
                      value: p > 0 ? p : null,
                      color: const Color(0xFF4CAF50),
                      backgroundColor: Colors.grey.shade200,
                      minHeight: 8,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      p > 0 ? '${(p * 100).toStringAsFixed(1)}%' : 'Connecting...',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              ValueListenableBuilder<String>(
                valueListenable: statusTextNotifier,
                builder: (_, status, __) => Text(
                  status,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ),
            ],
          ),
        );
      },
    );

    try {
      final plainDio = Dio();
      final tempDir = await getTemporaryDirectory();
      final savePath = '${tempDir.path}/Royal_Heritage_update.apk';

      await plainDio.download(
        url,
        savePath,
        options: Options(responseType: ResponseType.bytes, followRedirects: true),
        onReceiveProgress: (received, total) {
          if (total > 0) {
            progressNotifier.value = received / total;
            final recMB = (received / (1024 * 1024)).toStringAsFixed(1);
            final totMB = (total / (1024 * 1024)).toStringAsFixed(1);
            statusTextNotifier.value = '$recMB MB / $totMB MB';
          } else {
            final recMB = (received / (1024 * 1024)).toStringAsFixed(1);
            statusTextNotifier.value = '$recMB MB downloaded';
          }
        },
      );

      if (downloadDialogContext != null && downloadDialogContext!.mounted) {
        Navigator.pop(downloadDialogContext!);
      }
      progressNotifier.dispose();
      statusTextNotifier.dispose();

      // Verify the downloaded file is valid size
      final downloadedFile = File(savePath);
      final fileSize = await downloadedFile.length();
      if (fileSize < 2 * 1024 * 1024) {
        _showSnack('Download appears incomplete (${(fileSize / 1024).round()} KB). Please try again.', Colors.red.shade700);
        return;
      }

      final result = await OpenFile.open(savePath);
      if (result.type != ResultType.done) {
        _showSnack('Downloaded APK (${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB). ${result.message}', Colors.orange);
        _openBrowser(url);
      }
    } catch (e) {
      if (downloadDialogContext != null && downloadDialogContext!.mounted) {
        Navigator.pop(downloadDialogContext!);
      }
      progressNotifier.dispose();
      statusTextNotifier.dispose();
      _showSnack('Download failed: $e. Opening browser link...', Colors.red.shade700);
      _openBrowser(url);
    }
  }

  static void _showSnack(String message, Color color) {
    scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 5),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}


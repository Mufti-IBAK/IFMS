import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import '../network/api_client.dart';
import 'package:flutter/services.dart';
import '../../app.dart';

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
    // So 20038 becomes 21038, 22038, or 23038.
    // To correctly compare them, we extract the true run_number (e.g. 38).
    int getRunNumber(int code) {
      int remainder = code % 20000;
      return remainder % 1000;
    }

    final currentRun = getRunNumber(currentBuild);
    final latestRun = getRunNumber(latestBuild);

    return latestRun > currentRun;
  }

  static Future<void> _doCheck(BuildContext context, {bool showNoUpdateMessage = false}) async {
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

      if (response.data == null || (response.data as List).isEmpty) {
        if (showNoUpdateMessage && context.mounted) {
          _showSnack(context, '✓ App is up to date (v${packageInfo.version}+${packageInfo.buildNumber}, server returned empty)', Colors.green);
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
        if (showNoUpdateMessage && context.mounted) {
          _showUpdateDialog(context, latest);
        }
      } else {
        updateAvailableNotifier.value = false;
        if (showNoUpdateMessage && context.mounted) {
          _showSnack(context, '✓ App is up to date (v${packageInfo.version}+${packageInfo.buildNumber}, server: $latestVersion)', Colors.green);
        }
      }
    } catch (e) {
      debugPrint('Update check failed: $e');
      if (showNoUpdateMessage && context.mounted) {
        _showSnack(context, 'Update check failed: $e', Colors.orange);
      }
    }
  }


  /// Call when user taps the update button. Shows the update dialog if
  /// an update is available, or checks again if none was cached.
  static void showUpdateDialog(BuildContext context) {
    if (_pendingUpdateData != null) {
      _showUpdateDialog(context, _pendingUpdateData!);
    } else {
      // Trigger a fresh check with feedback
      checkForUpdates(context, showNoUpdateMessage: true);
    }
  }



  static void _showUpdateDialog(BuildContext context, Map<String, dynamic> data) {
    final version = data['version_number'] ?? 'New Version';
    final notes = data['release_notes'] ?? 'Performance improvements and bug fixes.';
    final downloadUrl = data['download_url'] as String?;

    if (downloadUrl == null) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
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
            onPressed: () => Navigator.pop(ctx),
            child: const Text('LATER'),
          ),
          TextButton.icon(
            onPressed: () {
              Navigator.pop(ctx);
              _openBrowser(downloadUrl);
            },
            icon: const Icon(Icons.open_in_browser, size: 18),
            label: const Text('DIRECT DOWNLOAD'),
            style: TextButton.styleFrom(foregroundColor: Colors.blue),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(ctx);
              _downloadAndInstall(context, downloadUrl);
            },
            icon: const Icon(Icons.download, size: 16),
            label: const Text('UPDATE VIA OTA'),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4CAF50), foregroundColor: Colors.white),
          ),
        ],
      ),
    );
  }

  static Future<void> _downloadAndInstall(BuildContext context, String url) async {
    _showSnack(context, 'Update is downloading in the background. You will be notified when it is ready.', Colors.green);

    try {
      final tempDir = await getExternalStorageDirectory();
      if (tempDir == null) return;
      
      final savePath = tempDir.path;

      await FlutterDownloader.enqueue(
        url: url,
        savedDir: savePath,
        fileName: 'Namanzo_IFMS_update.apk',
        showNotification: true, 
        openFileFromNotification: true,
        saveInPublicStorage: true,
      );

    } catch (e) {
      if (context.mounted) {
        _showSnack(
          context,
          'Download failed to start. Check your permissions and try again.',
          Colors.red.shade700,
        );
      }
    }
  }


  static void _showSnack(BuildContext context, String message, Color color) {
    scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color, duration: const Duration(seconds: 4)),
    );
  }
}

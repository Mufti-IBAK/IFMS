import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import '../network/api_client.dart';
import '../di/service_locator.dart';

/// Tracks whether an update is available — consumed by the AppBar badge.
final ValueNotifier<bool> updateAvailableNotifier = ValueNotifier(false);
Map<String, dynamic>? _pendingUpdateData;

class AppUpdater {
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
    final currentBuild = int.tryParse(currentBuildStr) ?? 0;
    return latestBuild > currentBuild;
  }

  static Future<void> _doCheck(BuildContext context, {bool showNoUpdateMessage = false}) async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();

      final apiClient = sl<ApiClient>();
      // Notice: relative path 'system_updates' to prevent Dio overriding baseUrl path
      final response = await apiClient.dio.get(
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

      if (isNew) {
        _pendingUpdateData = latest;
        updateAvailableNotifier.value = true;

        if (context.mounted) {
          _showUpdateSnack(context, latest);
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

  static void _showUpdateSnack(BuildContext context, Map<String, dynamic> data) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.system_update_alt, color: Colors.white, size: 18),
            SizedBox(width: 8),
            Text('New update available! Tap the ⬆ button to install.'),
          ],
        ),
        backgroundColor: Colors.green.shade700,
        duration: const Duration(seconds: 5),
        action: SnackBarAction(
          label: 'UPDATE',
          textColor: Colors.white,
          onPressed: () => _showUpdateDialog(context, data),
        ),
      ),
    );
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
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(ctx);
              _downloadAndInstall(context, downloadUrl);
            },
            icon: const Icon(Icons.download, size: 16),
            label: const Text('UPDATE NOW'),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4CAF50), foregroundColor: Colors.white),
          ),
        ],
      ),
    );
  }

  static Future<void> _downloadAndInstall(BuildContext context, String url) async {
    final progressNotifier = ValueNotifier<double>(0);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Downloading Update'),
        content: ValueListenableBuilder<double>(
          valueListenable: progressNotifier,
          builder: (_, p, __) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              LinearProgressIndicator(value: p > 0 ? p : null, color: const Color(0xFF4CAF50)),
              const SizedBox(height: 12),
              Text(
                p > 0 ? '${(p * 100).toStringAsFixed(0)}%  —  Please wait...' : 'Starting download...',
                style: const TextStyle(fontSize: 13),
              ),
            ],
          ),
        ),
      ),
    );

    try {
      // Use a plain Dio — no auth interceptors needed for public Supabase Storage URL
      final plainDio = Dio();
      final tempDir = await getTemporaryDirectory();
      final savePath = '${tempDir.path}/Namanzo_IFMS_update.apk';

      await plainDio.download(
        url,
        savePath,
        options: Options(responseType: ResponseType.bytes, followRedirects: true),
        onReceiveProgress: (received, total) {
          if (total > 0) progressNotifier.value = received / total;
        },
      );

      progressNotifier.dispose();
      if (context.mounted) Navigator.pop(context);

      final result = await OpenFile.open(savePath);
      if (result.type != ResultType.done && context.mounted) {
        _showSnack(context, 'Could not open installer: ${result.message}', Colors.orange);
      }
    } catch (e) {
      progressNotifier.dispose();
      if (context.mounted) {
        Navigator.pop(context);
        _showSnack(
          context,
          'Download failed. Check your internet connection and try again.',
          Colors.red.shade700,
        );
      }
    }
  }

  static void _showSnack(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color, duration: const Duration(seconds: 4)),
    );
  }
}

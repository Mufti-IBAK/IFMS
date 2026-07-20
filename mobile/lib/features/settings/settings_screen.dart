import 'dart:io';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'settings_controller.dart';
import 'profile_screen.dart';

class SettingsScreen extends StatelessWidget {
  final SettingsController controller;

  const SettingsScreen({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final profile = controller.profile;
        final fontScalePct = (controller.fontScale * 100).toInt();

        return Scaffold(
          appBar: AppBar(
            title: const Text('APP SETTINGS'),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // User Profile Header Card
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: AppColors.outlineVariant, width: 1),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 36,
                              backgroundColor: AppColors.surfaceContainerHigh,
                              backgroundImage: profile?.profilePicPath != null &&
                                      profile!.profilePicPath!.isNotEmpty &&
                                      File(profile.profilePicPath!).existsSync()
                                  ? FileImage(File(profile.profilePicPath!))
                                  : null,
                              child: profile?.profilePicPath == null ||
                                      profile!.profilePicPath!.isEmpty ||
                                      !File(profile.profilePicPath!).existsSync()
                                  ? const Icon(Icons.person, size: 36, color: AppColors.outline)
                                  : null,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    profile?.name ?? 'Anonymous User',
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      profile?.role ?? 'Role Unassigned',
                                      style: const TextStyle(
                                        color: AppColors.primary,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 32),
                        OutlinedButton.icon(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => ProfileScreen(controller: controller),
                              ),
                            );
                          },
                          icon: const Icon(Icons.edit_outlined),
                          label: const Text('Edit Profile & Career Biodata'),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 48),
                            side: const BorderSide(color: AppColors.primary),
                            foregroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                Text(
                  'SYSTEM PREFERENCES',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.bold,
                        color: AppColors.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 16),

                // Theme settings list tile
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: AppColors.outlineVariant, width: 1),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                    child: Column(
                      children: [
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.palette_outlined, color: AppColors.primary),
                          title: const Text('App Theme Mode', style: TextStyle(fontWeight: FontWeight.w600)),
                          trailing: DropdownButton<ThemeMode>(
                            value: controller.themeMode,
                            underline: const SizedBox(),
                            onChanged: (ThemeMode? newMode) {
                              if (newMode != null) {
                                controller.updateThemeMode(newMode);
                              }
                            },
                            items: const [
                              DropdownMenuItem(value: ThemeMode.system, child: Text('System')),
                              DropdownMenuItem(value: ThemeMode.light, child: Text('Light')),
                              DropdownMenuItem(value: ThemeMode.dark, child: Text('Dark')),
                            ],
                          ),
                        ),
                        const Divider(),
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          secondary: const Icon(Icons.fullscreen, color: AppColors.primary),
                          title: const Text('Full Screen Display', style: TextStyle(fontWeight: FontWeight.w600)),
                          subtitle: const Text('Hide system status & navigation overlays'),
                          value: controller.fullScreen,
                          activeColor: AppColors.primary,
                          onChanged: (val) {
                            controller.updateFullScreen(val);
                          },
                        ),
                        const Divider(),
                        // Font size settings
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.format_size_outlined, color: AppColors.primary),
                          title: const Text('Text Scale Adjustment', style: TextStyle(fontWeight: FontWeight.w600)),
                          subtitle: Text('Current scale: $fontScalePct%'),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Slider(
                            value: controller.fontScale,
                            min: 0.1,
                            max: 2.0,
                            divisions: 19,
                            activeColor: AppColors.primary,
                            inactiveColor: AppColors.surfaceContainerHigh,
                            label: '$fontScalePct%',
                            onChanged: (val) {
                              controller.updateFontScale(val);
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: const [
                              Text('10%', style: TextStyle(fontSize: 10, color: AppColors.outline)),
                              Text('50% (Default)', style: TextStyle(fontSize: 11, color: AppColors.outline, fontWeight: FontWeight.bold)),
                              Text('200%', style: TextStyle(fontSize: 10, color: AppColors.outline)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class UserProfile {
  final String name;
  final String email;
  final String phone;
  final String dob;
  final String gender;
  final String careerBio;
  final String role;
  final String? profilePicPath;

  UserProfile({
    required this.name,
    required this.email,
    required this.phone,
    required this.dob,
    required this.gender,
    required this.careerBio,
    required this.role,
    this.profilePicPath,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'email': email,
        'phone': phone,
        'dob': dob,
        'gender': gender,
        'careerBio': careerBio,
        'role': role,
        'profilePicPath': profilePicPath,
      };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        name: json['name'] ?? '',
        email: json['email'] ?? '',
        phone: json['phone'] ?? '',
        dob: json['dob'] ?? '',
        gender: json['gender'] ?? '',
        careerBio: json['careerBio'] ?? '',
        role: json['role'] ?? 'Casual Staff',
        profilePicPath: json['profilePicPath'],
      );

  UserProfile copyWith({
    String? name,
    String? email,
    String? phone,
    String? dob,
    String? gender,
    String? careerBio,
    String? role,
    String? profilePicPath,
  }) {
    return UserProfile(
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      dob: dob ?? this.dob,
      gender: gender ?? this.gender,
      careerBio: careerBio ?? this.careerBio,
      role: role ?? this.role,
      profilePicPath: profilePicPath ?? this.profilePicPath,
    );
  }
}

class SettingsController extends ChangeNotifier {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  ThemeMode _themeMode = ThemeMode.system;
  double _fontScale = 0.5;
  bool _fullScreen = false;
  UserProfile? _profile;

  ThemeMode get themeMode => _themeMode;
  double get fontScale => _fontScale;
  bool get fullScreen => _fullScreen;
  UserProfile? get profile => _profile;

  Future<void> loadSettings() async {
    try {
      final themeStr = await _storage.read(key: 'settings_theme_mode');
      if (themeStr != null) {
        _themeMode = ThemeMode.values.firstWhere(
          (e) => e.toString() == themeStr,
          orElse: () => ThemeMode.system,
        );
      }

      final scaleStr = await _storage.read(key: 'settings_font_scale');
      if (scaleStr != null) {
        _fontScale = double.tryParse(scaleStr) ?? 0.5;
      }

      final fullScreenStr = await _storage.read(key: 'settings_full_screen');
      if (fullScreenStr != null) {
        _fullScreen = fullScreenStr == 'true';
      } else {
        _fullScreen = false;
      }
      _applySystemUiMode();

      final profileStr = await _storage.read(key: 'settings_user_profile');
      if (profileStr != null) {
        _profile = UserProfile.fromJson(jsonDecode(profileStr));
      }
    } catch (_) {
      // Fallback to defaults on error
    }
    notifyListeners();
  }

  Future<void> updateThemeMode(ThemeMode newMode) async {
    _themeMode = newMode;
    await _storage.write(key: 'settings_theme_mode', value: newMode.toString());
    notifyListeners();
  }

  Future<void> updateFontScale(double newScale) async {
    _fontScale = newScale;
    await _storage.write(key: 'settings_font_scale', value: newScale.toString());
    notifyListeners();
  }

  Future<void> updateFullScreen(bool val) async {
    _fullScreen = val;
    await _storage.write(key: 'settings_full_screen', value: val.toString());
    _applySystemUiMode();
    notifyListeners();
  }

  void _applySystemUiMode() {
    if (_fullScreen) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    } else {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
    }
  }

  Future<void> updateProfile(UserProfile newProfile) async {
    _profile = newProfile;
    await _storage.write(key: 'settings_user_profile', value: jsonEncode(newProfile.toJson()));
    notifyListeners();
  }
}

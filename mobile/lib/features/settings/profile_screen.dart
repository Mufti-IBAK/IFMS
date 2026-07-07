import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme/app_colors.dart';
import 'settings_controller.dart';

class ProfileScreen extends StatefulWidget {
  final SettingsController controller;
  final bool isFromSignup;

  const ProfileScreen({
    super.key,
    required this.controller,
    this.isFromSignup = false,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _dobController;
  late final TextEditingController _bioController;

  String _selectedGender = 'Male';
  String _selectedRole = 'Casual Staff';
  String? _imagePath;

  final List<String> _roles = [
    'CEO',
    'GM',
    'Veterinarian',
    'Farm Manager',
    'Nutritionist',
    'Casual Staff',
  ];

  final List<String> _genders = ['Male', 'Female', 'Other'];

  @override
  void initState() {
    super.initState();
    final profile = widget.controller.profile;
    _nameController = TextEditingController(text: profile?.name ?? '');
    _emailController = TextEditingController(text: profile?.email ?? '');
    _phoneController = TextEditingController(text: profile?.phone ?? '');
    _dobController = TextEditingController(text: profile?.dob ?? '');
    _bioController = TextEditingController(text: profile?.careerBio ?? '');

    if (profile != null) {
      if (_genders.contains(profile.gender)) {
        _selectedGender = profile.gender;
      }
      if (_roles.contains(profile.role)) {
        _selectedRole = profile.role;
      }
      _imagePath = profile.profilePicPath;
    }

    if (widget.isFromSignup) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showProfileReminderDialog();
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _dobController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void _showProfileReminderDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: const [
            Icon(Icons.assignment_ind, color: AppColors.primary),
            SizedBox(width: 8),
            Text('Complete Profile'),
          ],
        ),
        content: const Text(
          'Welcome to NFarms! To help you manage tasks and receive role-based updates, please complete your biodata, demographics, and select your career role.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Get Started'),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 500,
        maxHeight: 500,
        imageQuality: 85,
      );
      if (pickedFile != null) {
        setState(() {
          _imagePath = pickedFile.path;
        });
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error picking profile picture.')),
      );
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 25)),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _dobController.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      final updatedProfile = UserProfile(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        dob: _dobController.text.trim(),
        gender: _selectedGender,
        careerBio: _bioController.text.trim(),
        role: _selectedRole,
        profilePicPath: _imagePath,
      );
      widget.controller.updateProfile(updatedProfile);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully!')),
      );
      if (widget.isFromSignup) {
        Navigator.of(context).pushReplacementNamed('/home');
      } else {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isFromSignup ? 'Create Profile' : 'Edit Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Profile Photo Input
              GestureDetector(
                onTap: _pickImage,
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 64,
                      backgroundColor: AppColors.surfaceContainerHigh,
                      backgroundImage: _imagePath != null ? FileImage(File(_imagePath!)) : null,
                      child: _imagePath == null
                          ? const Icon(Icons.person, size: 64, color: AppColors.outline)
                          : null,
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        size: 20,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Upload Profile Picture',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.outline,
                      fontWeight: FontWeight.w500,
                    ),
              ),
              const SizedBox(height: 32),

              // Inputs
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: AppColors.outlineVariant, width: 1),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'BIODATA & DEMOGRAPHICS',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              letterSpacing: 1.2,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                      ),
                      const Divider(height: 24),
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Full Name',
                          prefixIcon: Icon(Icons.badge_outlined),
                        ),
                        validator: (value) => value == null || value.trim().isEmpty ? 'Please enter your name' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Email Address',
                          prefixIcon: Icon(Icons.email_outlined),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) return 'Please enter email';
                          if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value.trim())) return 'Enter a valid email';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: 'Phone Number',
                          prefixIcon: Icon(Icons.phone_outlined),
                        ),
                        validator: (value) => value == null || value.trim().isEmpty ? 'Please enter phone number' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _dobController,
                        readOnly: true,
                        onTap: _selectDate,
                        decoration: const InputDecoration(
                          labelText: 'Date of Birth',
                          prefixIcon: Icon(Icons.calendar_today_outlined),
                        ),
                        validator: (value) => value == null || value.isEmpty ? 'Please select Date of Birth' : null,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _selectedGender,
                        items: _genders
                            .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedGender = val);
                        },
                        decoration: const InputDecoration(
                          labelText: 'Gender',
                          prefixIcon: Icon(Icons.wc_outlined),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: AppColors.outlineVariant, width: 1),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'CAREER PROFILE',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              letterSpacing: 1.2,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                      ),
                      const Divider(height: 24),
                      DropdownButtonFormField<String>(
                        value: _selectedRole,
                        items: _roles
                            .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedRole = val);
                        },
                        decoration: const InputDecoration(
                          labelText: 'Assign Role / Title',
                          prefixIcon: Icon(Icons.work_outline),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _bioController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Professional Summary / Bio',
                          prefixIcon: Icon(Icons.history_edu_outlined),
                          alignLabelWithHint: true,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              ElevatedButton(
                onPressed: _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 54),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Save Profile & Proceed',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

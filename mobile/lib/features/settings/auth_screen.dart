import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/network/api_client.dart';
import '../../core/sync/sync_manager.dart';
import '../../core/di/service_locator.dart';
import 'settings_controller.dart';

class AuthScreen extends StatefulWidget {
  final SettingsController controller;

  const AuthScreen({
    super.key,
    required this.controller,
  });

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isSignUp = false;
  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _isGoogleLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleEmailSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final apiClient = sl<ApiClient>();
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    try {
      if (_isSignUp) {
        final name = _nameController.text.trim();
        final phone = _phoneController.text.trim();

        await apiClient.signUpWithEmailPassword(
          email,
          password,
          fullName: name.isNotEmpty ? name : null,
          phone: phone.isNotEmpty ? phone : null,
        );

        final current = widget.controller.profile;
        final updatedProfile = UserProfile(
          name: name.isNotEmpty ? name : (current?.name ?? 'Farm Operator'),
          email: email,
          phone: phone,
          dob: current?.dob ?? '',
          gender: current?.gender ?? 'Male',
          careerBio: current?.careerBio ?? '',
          role: 'Staff',
        );
        await widget.controller.updateProfile(updatedProfile);

        // Immediate background sync
        sl<SyncManager>().syncAll();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Account registered successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pushReplacementNamed('/home');
        }
      } else {
        // Sign In
        final result = await apiClient.signInWithEmailPassword(email, password);
        final user = result['user'] as Map<String, dynamic>?;
        final userMetadata = user?['user_metadata'] as Map<String, dynamic>?;
        final name = userMetadata?['full_name'] as String? ?? '';
        final phone = userMetadata?['phone'] as String? ?? '';

        final current = widget.controller.profile;
        final updatedProfile = UserProfile(
          name: name.isNotEmpty ? name : (current?.name.isNotEmpty == true ? current!.name : 'Farm Operator'),
          email: email,
          phone: phone.isNotEmpty ? phone : (current?.phone ?? ''),
          dob: current?.dob ?? '',
          gender: current?.gender ?? 'Male',
          careerBio: current?.careerBio ?? '',
          role: 'Staff',
        );
        await widget.controller.updateProfile(updatedProfile);

        // Immediate background sync to restore all cloud data
        sl<SyncManager>().syncAll();

        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/home');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isGoogleLoading = true);
    final apiClient = sl<ApiClient>();

    try {
      final result = await apiClient.signInWithGoogle();
      final user = result['user'] as Map<String, dynamic>?;
      final userMetadata = user?['user_metadata'] as Map<String, dynamic>?;
      final email = user?['email'] as String? ?? '';
      final name = userMetadata?['full_name'] as String? ??
          userMetadata?['name'] as String? ??
          '';

      final current = widget.controller.profile;
      final updatedProfile = UserProfile(
        name: name.isNotEmpty ? name : (current?.name.isNotEmpty == true ? current!.name : 'Farm Operator'),
        email: email.isNotEmpty ? email : (current?.email ?? ''),
        phone: current?.phone ?? '',
        dob: current?.dob ?? '',
        gender: current?.gender ?? 'Male',
        careerBio: current?.careerBio ?? '',
        role: 'Staff',
      );
      await widget.controller.updateProfile(updatedProfile);

      // Immediate background sync to pull and push
      sl<SyncManager>().syncAll();

      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/home');
      }
    } catch (e) {
      if (mounted) {
        final errStr = e.toString().replaceAll('Exception: ', '');
        if (!errStr.contains('cancelled')) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errStr),
              backgroundColor: Colors.red.shade700,
            ),
          );
        }
      }
    } finally {
      if (mounted) setState(() => _isGoogleLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Brand logo / header
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.asset(
                    'assets/images/app_icon.png',
                    width: 76,
                    height: 76,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.agriculture_rounded,
                      size: 76,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'Royal Golden',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w900,
                      ),
                ),
                Text(
                  'INTEGRATED FARMS LTD',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: AppColors.secondary,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2.0,
                      ),
                ),
                const SizedBox(height: 36),

                // Form card
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: AppColors.outlineVariant, width: 1),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(22.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          _isSignUp ? 'CREATE YOUR ACCOUNT' : 'LOGIN TO YOUR ACCOUNT',
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                letterSpacing: 1.2,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _isSignUp
                              ? 'Enter your farm credentials to access real-time records.'
                              : 'Sign in to sync farm records and operations across all devices.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const Divider(height: 28),

                        if (_isSignUp) ...[
                          TextFormField(
                            controller: _nameController,
                            keyboardType: TextInputType.name,
                            decoration: const InputDecoration(
                              labelText: 'Full Name',
                              prefixIcon: Icon(Icons.person_outline),
                            ),
                            validator: (value) =>
                                value == null || value.trim().isEmpty ? 'Please enter your name' : null,
                          ),
                          const SizedBox(height: 14),
                          TextFormField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            decoration: const InputDecoration(
                              labelText: 'Phone Number',
                              prefixIcon: Icon(Icons.phone_outlined),
                            ),
                            validator: (value) =>
                                value == null || value.trim().isEmpty ? 'Please enter phone number' : null,
                          ),
                          const SizedBox(height: 14),
                        ],

                        // Email
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
                        const SizedBox(height: 14),

                        // Password
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                            ),
                          ),
                          validator: (value) =>
                              value == null || value.length < 6 ? 'Password must be at least 6 characters' : null,
                        ),

                        if (_isSignUp) ...[
                          const SizedBox(height: 14),
                          TextFormField(
                            controller: _confirmPasswordController,
                            obscureText: _obscurePassword,
                            decoration: const InputDecoration(
                              labelText: 'Confirm Password',
                              prefixIcon: Icon(Icons.lock_clock_outlined),
                            ),
                            validator: (value) {
                              if (value != _passwordController.text) return 'Passwords do not match';
                              return null;
                            },
                          ),
                        ],
                        const SizedBox(height: 22),

                        // Primary Action Button (Email/Password)
                        ElevatedButton(
                          onPressed: (_isLoading || _isGoogleLoading) ? null : _handleEmailSubmit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 48),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : Text(
                                  _isSignUp ? 'Create Account' : 'Sign In with Email',
                                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                                ),
                        ),

                        const SizedBox(height: 18),

                        // OR Divider
                        Row(
                          children: [
                            const Expanded(child: Divider()),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12.0),
                              child: Text(
                                'OR CONTINUE WITH',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey.shade500,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ),
                            const Expanded(child: Divider()),
                          ],
                        ),

                        const SizedBox(height: 18),

                        // Google Sign-In Button
                        OutlinedButton(
                          onPressed: (_isLoading || _isGoogleLoading) ? null : _handleGoogleSignIn,
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF1F1F1F),
                            side: BorderSide(color: Colors.grey.shade300, width: 1.2),
                            minimumSize: const Size(double.infinity, 48),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 0,
                          ),
                          child: _isGoogleLoading
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(strokeWidth: 2.2),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 22,
                                      height: 22,
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Center(
                                        child: Text(
                                          'G',
                                          style: TextStyle(
                                            color: Color(0xFF4285F4),
                                            fontWeight: FontWeight.w900,
                                            fontSize: 18,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    const Text(
                                      'Continue with Google',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF1F1F1F),
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Toggle Auth Mode
                TextButton(
                  onPressed: () => setState(() => _isSignUp = !_isSignUp),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                  ),
                  child: Text(
                    _isSignUp
                        ? 'Already have an account? Sign In'
                        : 'New to Royal Golden Farms? Register Here',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

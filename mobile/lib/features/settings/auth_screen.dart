import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'settings_controller.dart';
import 'profile_screen.dart';

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
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isSignUp = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      if (_isSignUp) {
        // Collect email and phone numbers for verification
        final email = _emailController.text.trim();
        final phone = _phoneController.text.trim();

        // As requested: "do not implement the sign up now, until i tell you what feature each role would have access to"
        // Show account creation success popup and prompt to complete profile
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: Row(
              children: const [
                Icon(Icons.check_circle_outline, color: Colors.green),
                SizedBox(width: 8),
                Text('Account Initialized'),
              ],
            ),
            content: Text(
              'A verification email and SMS notification will be set up to send sign up details to:\n\nEmail: $email\nPhone: $phone\n\nPlease proceed to complete your career profile details now!',
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close dialog
                  
                  // Initialize a blank profile with email and phone
                  final emptyProfile = UserProfile(
                    name: '',
                    email: email,
                    phone: phone,
                    dob: '',
                    gender: 'Male',
                    careerBio: '',
                    role: 'Casual Staff',
                  );
                  widget.controller.updateProfile(emptyProfile);

                  // Open ProfileScreen to fill details
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => ProfileScreen(
                        controller: widget.controller,
                        isFromSignup: true,
                      ),
                    ),
                  );
                },
                child: const Text('Complete Profile'),
              ),
            ],
          ),
        );
      } else {
        // Simple mock login for local testing
        Navigator.of(context).pushReplacementNamed('/home');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Brand logo / header
                const Icon(
                  Icons.agriculture_outlined,
                  size: 80,
                  color: AppColors.primary,
                ),
                const SizedBox(height: 12),
                Text(
                  'NFarms Portal',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w900,
                      ),
                ),
                Text(
                  'Integrated Farm Management System',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.outline,
                      ),
                ),
                const SizedBox(height: 48),

                // Form card
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: AppColors.outlineVariant, width: 1),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          _isSignUp ? 'REGISTER ACCOUNT' : 'LOGIN TO ACCOUNT',
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                letterSpacing: 1.2,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                          textAlign: TextAlign.center,
                        ),
                        const Divider(height: 24),

                        // Inputs
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
                        if (_isSignUp) ...[
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
                        ],
                        const SizedBox(height: 16),
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
                          validator: (value) => value == null || value.length < 6 ? 'Password must be at least 6 characters' : null,
                        ),
                        if (_isSignUp) ...[
                          const SizedBox(height: 16),
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
                        const SizedBox(height: 24),

                        // Submit Button
                        ElevatedButton(
                          onPressed: _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            _isSignUp ? 'Create Account' : 'Sign In',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
                        : 'New to NFarms? Register Here',
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

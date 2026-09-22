import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../state/app_state_controller.dart';
import '../navigation/app_routes.dart';

class AuthScreen extends StatefulWidget {
  final AppStateController controller;

  const AuthScreen({
    super.key,
    required this.controller,
  });

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isRegistering = false;
  bool _isLoading = false;
  String? _errorMessage;

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (_isRegistering) {
        await widget.controller.authService.registerWithEmailPassword(
          email: _emailController.text,
          password: _passwordController.text,
          fullName: _nameController.text,
          phone: _phoneController.text,
        );
      } else {
        await widget.controller.authService.signInWithEmailPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.tertiary,
            content: Text(
              _isRegistering ? 'Account registered successfully!' : 'Signed in successfully!',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        );

        final uid = widget.controller.authService.currentUserId;
        if (uid != null) {
          final role = await widget.controller.profileService.getUserRole(uid);
          if (mounted) {
            if (role == null || role.isEmpty) {
              Navigator.of(context).pushNamedAndRemoveUntil(
                AppRoutes.roleSelection,
                (route) => false,
              );
            } else if (role == 'rider') {
              widget.controller.setUserRole('rider');
              Navigator.of(context).pushNamedAndRemoveUntil(
                AppRoutes.driver,
                (route) => false,
              );
            } else {
              widget.controller.setUserRole('user');
              Navigator.of(context).pushNamedAndRemoveUntil(
                AppRoutes.mainScaffold,
                (route) => false,
              );
            }
          }
        } else {
          Navigator.of(context).pop();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Text(
          _isRegistering ? 'Register Civic Profile' : 'Civic Account Login',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Civic Emblem Header
                Center(
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: AppColors.primaryFixed,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.2), width: 2),
                    ),
                    child: const Icon(Icons.verified_user, color: AppColors.primary, size: 32),
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: Text(
                    _isRegistering ? 'Create Emergency Account' : 'Welcome to ResQ Dispatch',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                  ),
                ),
                const SizedBox(height: 4),
                const Center(
                  child: Text(
                    'Your medical telemetry is protected with 256-bit civic encryption.',
                    style: TextStyle(fontSize: 12, color: AppColors.secondary),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 24),

                // Error Message Banner
                if (_errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primaryFixed,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: AppColors.primary, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Register-specific fields
                if (_isRegistering) ...[
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Full Name',
                      prefixIcon: Icon(Icons.person_outline),
                      border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                    ),
                    validator: (val) => (val == null || val.trim().isEmpty) ? 'Please enter your full name' : null,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Emergency Mobile Number',
                      prefixIcon: Icon(Icons.phone_outlined),
                      border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                    ),
                    validator: (val) => (val == null || val.trim().length < 10) ? 'Enter valid 10-digit phone' : null,
                  ),
                  const SizedBox(height: 14),
                ],

                // Email Field
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email Address',
                    prefixIcon: Icon(Icons.email_outlined),
                    border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                  ),
                  validator: (val) => (val == null || !val.contains('@')) ? 'Enter valid email address' : null,
                ),
                const SizedBox(height: 14),

                // Password Field
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  validator: (val) => (val == null || val.length < 6) ? 'Password must be at least 6 characters' : null,
                ),
                const SizedBox(height: 24),

                // Submit Button
                ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(56),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                        )
                      : Text(
                          _isRegistering ? 'CREATE ACCOUNT & VERIFY' : 'SIGN IN SECURELY',
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, letterSpacing: 0.5),
                        ),
                ),
                const SizedBox(height: 14),

                // Toggle Login / Register
                TextButton(
                  onPressed: () {
                    setState(() {
                      _isRegistering = !_isRegistering;
                      _errorMessage = null;
                    });
                  },
                  child: Text(
                    _isRegistering
                        ? 'Already have an account? Sign In'
                        : 'New to ResQ? Create an account',
                    style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700),
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

import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../state/app_state_controller.dart';
import '../navigation/app_routes.dart';

class RoleSelectionScreen extends StatefulWidget {
  final AppStateController controller;

  const RoleSelectionScreen({
    super.key,
    required this.controller,
  });

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  bool _isLoading = false;
  String? _selectedRole;

  Future<void> _confirmSelection(String role) async {
    setState(() {
      _selectedRole = role;
      _isLoading = true;
    });

    try {
      await widget.controller.selectRole(role);

      if (mounted) {
        if (role == 'rider') {
          Navigator.of(context).pushNamedAndRemoveUntil(
            AppRoutes.driver,
            (route) => false,
          );
        } else {
          Navigator.of(context).pushNamedAndRemoveUntil(
            AppRoutes.mainScaffold,
            (route) => false,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.error,
            content: Text('Error saving role: $e'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text(
          'Choose your account type',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),
              const Text(
                'Choose your account type',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Please select your account type. This selection is saved permanently in your profile.',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.secondary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 28),

              // Option 1: USER
              _buildRoleCard(
                role: 'user',
                badgeText: 'CITIZEN',
                title: 'USER',
                subtitle: 'For a person who needs emergency assistance.',
                buttonLabel: 'CONTINUE AS USER',
                icon: Icons.person_rounded,
                primaryColor: AppColors.primary,
                isLoading: _isLoading && _selectedRole == 'user',
                onTap: _isLoading ? null : () => _confirmSelection('user'),
              ),

              const SizedBox(height: 20),

              // Option 2: RIDER
              _buildRoleCard(
                role: 'rider',
                badgeText: 'RESPONDER',
                title: 'RIDER',
                subtitle: 'For an ambulance/responder who receives emergency requests.',
                buttonLabel: 'CONTINUE AS RIDER',
                icon: Icons.local_shipping_rounded,
                primaryColor: AppColors.tertiary,
                isLoading: _isLoading && _selectedRole == 'rider',
                onTap: _isLoading ? null : () => _confirmSelection('rider'),
              ),

              const SizedBox(height: 24),

              if (_isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard({
    required String role,
    required String badgeText,
    required String title,
    required String subtitle,
    required String buttonLabel,
    required IconData icon,
    required Color primaryColor,
    required bool isLoading,
    required VoidCallback? onTap,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: primaryColor.withValues(alpha: 0.35),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: primaryColor, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        badgeText,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: primaryColor,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.onSurface,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 18),
          ElevatedButton(
            onPressed: onTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                : Text(
                    buttonLabel,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                      letterSpacing: 0.5,
                    ),
                  ),
          ),
        ],
      ),
    ),
    );
  }
}

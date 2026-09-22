import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../state/app_state_controller.dart';
import '../navigation/app_routes.dart';

class ProfileScreen extends StatelessWidget {
  final AppStateController controller;

  const ProfileScreen({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final profile = controller.medicalProfile;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text('My Profile', style: TextStyle(fontWeight: FontWeight.w800)),
        centerTitle: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // User Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 30,
                      backgroundColor: AppColors.primary,
                      child: Text(
                        'AS',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                profile.fullName,
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.verified, color: AppColors.primary, size: 18),
                            ],
                          ),
                          const SizedBox(height: 2),
                          const Text('+91 98765 43210', style: TextStyle(fontSize: 13, color: AppColors.secondary)),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.tertiaryFixed,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'VERIFIED CIVIC RESPONDER',
                              style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: AppColors.tertiary),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Menu Navigation
              _buildMenuCard([
                _buildMenuItem(
                  icon: Icons.medical_information,
                  title: 'Emergency Medical Profile',
                  subtitle: 'Blood group O+, allergies, medications',
                  onTap: () => Navigator.of(context).pushNamed(AppRoutes.emergencyProfile),
                ),
                _buildMenuItem(
                  icon: Icons.history,
                  title: 'Activity & Dispatch Records',
                  subtitle: 'View historical ambulance runs',
                  onTap: () => Navigator.of(context).pushNamed(AppRoutes.activity),
                ),
              ]),
              const SizedBox(height: 14),

              _buildMenuCard([
                _buildMenuItem(
                  icon: Icons.tune,
                  title: 'System Settings',
                  subtitle: 'Siren, haptics, hold duration',
                  onTap: () => Navigator.of(context).pushNamed(AppRoutes.settings),
                ),
                _buildMenuItem(
                  icon: Icons.security,
                  title: 'Privacy & Security Protocol',
                  subtitle: 'AES-256 local storage & data policy',
                  onTap: () => Navigator.of(context).pushNamed(AppRoutes.privacySecurity),
                ),
                _buildMenuItem(
                  icon: Icons.info_outline,
                  title: 'About ResQ Protocol',
                  subtitle: 'Version 2.4.0 • Civic Operational Dispatch',
                  onTap: () {
                    showAboutDialog(
                      context: context,
                      applicationName: 'ResQ Emergency Dispatch',
                      applicationVersion: '2.4.0',
                      applicationLegalese: 'Civic Operational Ambulance Dispatch Framework',
                    );
                  },
                ),
              ]),
              _buildMenuCard([
                _buildMenuItem(
                  icon: Icons.airport_shuttle,
                  title: 'Ambulance Driver Terminal',
                  subtitle: 'Switch device role to Ambulance Phone (main)',
                  onTap: () => Navigator.of(context).pushNamed(AppRoutes.driver),
                ),
              ]),
              const SizedBox(height: 14),

              // Firebase Account Card
              _buildMenuCard([
                if (controller.authService.isAuthenticated)
                  _buildMenuItem(
                    icon: Icons.logout,
                    title: 'Sign Out of Civic Account',
                    subtitle: 'Signed in as ${controller.authService.currentUser?.email}',
                    onTap: () async {
                      await controller.signOut();
                      if (context.mounted) {
                        Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.auth, (route) => false);
                      }
                    },
                  )
                else
                  _buildMenuItem(
                    icon: Icons.login,
                    title: 'Sign In / Register Account',
                    subtitle: 'Sync medical profile & emergency history to Firebase',
                    onTap: () => Navigator.of(context).pushNamed(AppRoutes.auth),
                  ),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuCard(List<Widget> items) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(children: items),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: AppColors.secondary, size: 22),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                  Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.secondary)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, size: 20, color: AppColors.secondary),
          ],
        ),
      ),
    );
  }
}

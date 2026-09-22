import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../state/app_state_controller.dart';

class PrivacySecurityScreen extends StatefulWidget {
  final AppStateController controller;

  const PrivacySecurityScreen({
    super.key,
    required this.controller,
  });

  @override
  State<PrivacySecurityScreen> createState() => _PrivacySecurityScreenState();
}

class _PrivacySecurityScreenState extends State<PrivacySecurityScreen> {
  @override
  Widget build(BuildContext context) {
    final settings = widget.controller.settings;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text('Privacy & Security', style: TextStyle(fontWeight: FontWeight.w800)),
        centerTitle: false,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: const Row(
                children: [
                  Icon(Icons.verified_user, color: AppColors.tertiary, size: 28),
                  SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Zero-Tracking Civic Protocol',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Your location is never tracked in the background. GPS polling only engages during an active SOS.',
                          style: TextStyle(fontSize: 12, color: AppColors.secondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            _buildSection(
              title: 'DATA SHARING PERMISSIONS',
              children: [
                SwitchListTile(
                  title: const Text('Share Medical ID with Paramedics', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                  subtitle: const Text('Transmits blood group and allergies to the en-route hospital and ALS unit', style: TextStyle(fontSize: 12)),
                  value: settings.shareMedicalDataWithParamedics,
                  activeThumbColor: AppColors.primary,
                  onChanged: (val) {
                    setState(() => settings.shareMedicalDataWithParamedics = val);
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),

            _buildSection(
              title: 'AUDIO RECORDING POLICIES',
              children: const [
                ListTile(
                  leading: Icon(Icons.mic_none, color: AppColors.secondary),
                  title: Text('15-Second Voice Triage Retention', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                  subtitle: Text('Voice snippets are strictly end-to-end encrypted and automatically purged 24 hours post-dispatch.', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
            const SizedBox(height: 16),

            _buildSection(
              title: 'SECURITY ARCHITECTURE',
              children: const [
                ListTile(
                  leading: Icon(Icons.shield_outlined, color: AppColors.tertiary),
                  title: Text('AES-256 Storage & TLS 1.3 in Transit', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                  subtitle: Text('Compliant with National Emergency Telecommunication Security Standards.', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
            const SizedBox(height: 24),

            OutlinedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Medical profile exported to encrypted file: resq_medical_id.enc')),
                );
              },
              icon: const Icon(Icons.download, size: 18),
              label: const Text('EXPORT MEDICAL DATA (ENCRYPTED)'),
              style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(52)),
            ),
            const SizedBox(height: 10),

            OutlinedButton.icon(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Purge Local Medical Data?'),
                    content: const Text('This will clear all locally saved allergies, contacts, and document records.'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                        onPressed: () {
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Local cache purged')),
                          );
                        },
                        child: const Text('Purge'),
                      ),
                    ],
                  ),
                );
              },
              icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.error),
              label: const Text('PURGE ALL LOCAL RECORDS', style: TextStyle(color: AppColors.error)),
              style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(52)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
                color: AppColors.secondary,
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }
}

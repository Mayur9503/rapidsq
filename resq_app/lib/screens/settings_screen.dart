import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../state/app_state_controller.dart';

class SettingsScreen extends StatefulWidget {
  final AppStateController controller;

  const SettingsScreen({
    super.key,
    required this.controller,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final settings = widget.controller.settings;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text('Settings', style: TextStyle(fontWeight: FontWeight.w800)),
        centerTitle: false,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildSection(
              title: 'EMERGENCY HARDWARE & ALERTS',
              children: [
                SwitchListTile(
                  title: const Text('Siren Armed on SOS', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                  subtitle: const Text('Sounds loud emergency acoustic warning during dispatch countdown', style: TextStyle(fontSize: 12)),
                  value: settings.sirenArmed,
                  activeThumbColor: AppColors.primary,
                  onChanged: (val) {
                    setState(() => settings.sirenArmed = val);
                  },
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text('Tactile Haptic Feedback', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                  subtitle: const Text('Vibrates phone to confirm hold trigger and dispatch transitions', style: TextStyle(fontSize: 12)),
                  value: settings.hapticFeedback,
                  activeThumbColor: AppColors.primary,
                  onChanged: (val) {
                    setState(() => settings.hapticFeedback = val);
                  },
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text('Auto-Dial 112 on SOS', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                  subtitle: const Text('Simultaneously bridges telephone call to statutory national emergency', style: TextStyle(fontSize: 12)),
                  value: settings.autoDial112,
                  activeThumbColor: AppColors.primary,
                  onChanged: (val) {
                    setState(() => settings.autoDial112 = val);
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),

            _buildSection(
              title: 'TRIGGER DURATION',
              children: [
                ListTile(
                  title: const Text('SOS Button Hold Duration', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                  subtitle: Text('${settings.sosHoldDurationSeconds} Seconds (Prevents accidental activation)', style: const TextStyle(fontSize: 12)),
                  trailing: DropdownButton<int>(
                    value: settings.sosHoldDurationSeconds,
                    underline: const SizedBox(),
                    items: const [
                      DropdownMenuItem(value: 1, child: Text('1s (Rapid)')),
                      DropdownMenuItem(value: 2, child: Text('2s (Standard)')),
                      DropdownMenuItem(value: 3, child: Text('3s (Deliberate)')),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => settings.sosHoldDurationSeconds = val);
                      }
                    },
                  ),
                ),
              ],
            ),
            _buildSection(
              title: 'EMERGENCY CONTACTS & WOMEN SAFETY',
              children: [
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFFAF5FF),
                    child: Icon(Icons.shield, color: Color(0xFF7C3AED), size: 20),
                  ),
                  title: const Text('Auto-Notify Contacts on Safety SOS', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                  subtitle: Text(
                    widget.controller.medicalProfile.contacts.isNotEmpty
                        ? 'Primary: ${widget.controller.medicalProfile.contacts.first.name} (${widget.controller.medicalProfile.contacts.first.phone})'
                        : 'No contacts configured yet',
                    style: const TextStyle(fontSize: 12),
                  ),
                  trailing: const Icon(Icons.check_circle, color: Color(0xFF7C3AED), size: 20),
                ),
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Text(
                    'When Women Safety SOS is activated, emergency coordinates are instantly relayed to your registered emergency contacts and local quick response patrols.',
                    style: TextStyle(fontSize: 11, color: AppColors.secondary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            _buildSection(
              title: 'DISPLAY & INTERFACE',
              children: [
                SwitchListTile(
                  title: const Text('High-Contrast Sunlight Mode', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                  subtitle: const Text('Maximizes black-on-white road and card contrast for direct glare', style: TextStyle(fontSize: 12)),
                  value: settings.highContrastMode,
                  activeThumbColor: AppColors.primary,
                  onChanged: (val) {
                    setState(() => settings.highContrastMode = val);
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),

            ElevatedButton.icon(
              onPressed: () {
                widget.controller.resetToIdle();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Mock state reset to initial default')),
                );
              },
              icon: const Icon(Icons.restart_alt, color: Colors.white),
              label: const Text('RESET DEMO STATE'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.inverseSurface,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(52),
              ),
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

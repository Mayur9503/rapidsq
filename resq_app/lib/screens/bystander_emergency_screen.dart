import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../state/app_state_controller.dart';
import '../models/emergency_request.dart';
import '../widgets/voice_recorder_widget.dart';
import '../navigation/app_routes.dart';

class BystanderEmergencyScreen extends StatefulWidget {
  final AppStateController controller;

  const BystanderEmergencyScreen({
    super.key,
    required this.controller,
  });

  @override
  State<BystanderEmergencyScreen> createState() => _BystanderEmergencyScreenState();
}

class _BystanderEmergencyScreenState extends State<BystanderEmergencyScreen> {
  String? _voiceNote;
  bool _isSending = false;

  void _sendToResponder() {
    setState(() => _isSending = true);
    widget.controller.submitHelpSomeoneElse(
      location: widget.controller.userLocation,
      consciousness: ConsciousnessState.unconscious,
      visibleTraumas: ['Bystander Immediate Emergency Call'],
      category: EmergencyCategory.bystanderAccident,
      voiceNoteDuration: _voiceNote ?? 'Instant Condition Beacon',
      notes: 'Dispatched via 1-Tap Bystander Emergency Mode',
    );
    Navigator.of(context).pushReplacementNamed(AppRoutes.sosSearching);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text('Bystander Emergency', style: TextStyle(fontWeight: FontWeight.w800)),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Emergency Alert Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primaryFixed,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                ),
                child: const Column(
                  children: [
                    Icon(Icons.volunteer_activism, size: 36, color: AppColors.primary),
                    SizedBox(height: 8),
                    Text(
                      'Someone Nearby Needs Help',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Zero-login emergency dispatch. Capture a fast 15-second voice description of the victim.',
                      style: TextStyle(fontSize: 13, color: AppColors.onSurfaceVariant),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 15-Second Voice Recorder UI
              VoiceRecorderWidget(
                onVoiceRecorded: (dur) {
                  setState(() => _voiceNote = dur);
                },
                onSend: _sendToResponder,
              ),
              const SizedBox(height: 20),

              // Location Telemetry Tag
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.pin_drop, color: AppColors.primary, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        widget.controller.userLocation.title,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.onSurface,
                        ),
                      ),
                    ),
                    const Text(
                      'GPS ±3m',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: AppColors.tertiary,
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Send to Responder Button
              ElevatedButton.icon(
                onPressed: _isSending ? null : _sendToResponder,
                icon: const Icon(Icons.send_rounded, color: Colors.white, size: 22),
                label: const Text('SEND TO EMERGENCY RESPONDER'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(56),
                ),
              ),
              const SizedBox(height: 12),

              // Direct 112 Fallback Button
              OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Calling 112 National Police & Medical...')),
                  );
                },
                icon: const Icon(Icons.phone, size: 18, color: AppColors.error),
                label: const Text(
                  'OR DIAL 112 DIRECTLY',
                  style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w800),
                ),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


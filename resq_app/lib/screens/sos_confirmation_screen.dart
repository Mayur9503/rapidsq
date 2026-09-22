import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../state/app_state_controller.dart';
import '../state/emergency_enums.dart';
import '../navigation/app_routes.dart';

class SosConfirmationScreen extends StatefulWidget {
  final AppStateController controller;

  const SosConfirmationScreen({
    super.key,
    required this.controller,
  });

  @override
  State<SosConfirmationScreen> createState() => _SosConfirmationScreenState();
}

class _SosConfirmationScreenState extends State<SosConfirmationScreen> {
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onControllerStateChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerStateChanged);
    super.dispose();
  }

  void _onControllerStateChanged() {
    if (!mounted || _navigated) return;
    if (widget.controller.state == EmergencyState.searching ||
        widget.controller.sosCountdownRemaining <= 0) {
      _navigated = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.of(context).pushReplacementNamed(AppRoutes.sosSearching);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        final location = widget.controller.userLocation;
        final profile = widget.controller.medicalProfile;
        final seconds = widget.controller.sosCountdownRemaining;

        return Scaffold(
          backgroundColor: AppColors.surface,
          appBar: AppBar(
            title: const Text(
              'Confirm Emergency SOS',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            leading: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                widget.controller.cancelSOSCountdown();
                Navigator.of(context).pop();
              },
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
              // Circular Countdown Visual
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 120,
                    height: 120,
                    child: CircularProgressIndicator(
                      value: seconds / 5.0,
                      strokeWidth: 8,
                      color: AppColors.primary,
                      backgroundColor: AppColors.primaryFixed,
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$seconds',
                        style: const TextStyle(
                          fontSize: 44,
                          fontWeight: FontWeight.w900,
                          color: AppColors.primary,
                          height: 1.0,
                        ),
                      ),
                      const Text(
                        'SECONDS',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.0,
                          color: AppColors.secondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                'Auto-Dispatching Ambulance',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'High-priority triage payload will be broadcast to nearest units automatically when timer expires.',
                style: TextStyle(fontSize: 13, color: AppColors.secondary, height: 1.4),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              // Dispatch Target Location Card
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primaryFixed,
                      ),
                      child: const Icon(Icons.location_on, color: AppColors.primary),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'DISPATCH LOCATION',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.8,
                              color: AppColors.secondary,
                            ),
                          ),
                          Text(
                            location.title,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.onSurface,
                            ),
                          ),
                          Text(
                            location.subtitle,
                            style: const TextStyle(fontSize: 12, color: AppColors.secondary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Medical Triage Snapshot
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildItem('Patient', profile.fullName),
                    _buildItem('Blood', profile.bloodGroup, isHighlight: true),
                    _buildItem('Age', '${profile.age} Yrs'),
                    _buildItem('Allergies', profile.allergies),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Instant Dispatch Now Button
              ElevatedButton.icon(
                onPressed: () {
                  _navigated = true;
                  widget.controller.sendSOSNow();
                  Navigator.of(context).pushReplacementNamed(AppRoutes.sosSearching);
                },
                icon: const Icon(Icons.flash_on, color: Colors.white, size: 22),
                label: const Text('DISPATCH AMBULANCE NOW'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(56),
                ),
              ),
              const SizedBox(height: 12),

              // Cancel SOS Button
              OutlinedButton.icon(
                onPressed: () {
                  widget.controller.cancelSOSCountdown();
                  Navigator.of(context).pop();
                },
                icon: const Icon(Icons.cancel_outlined, size: 20, color: AppColors.secondary),
                label: const Text(
                  'CANCEL SOS REQUEST',
                  style: TextStyle(color: AppColors.secondary, fontWeight: FontWeight.w700),
                ),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(56),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  },
);
}

  Widget _buildItem(String label, String value, {bool isHighlight = false}) {
    return Column(
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            color: AppColors.secondary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: isHighlight ? AppColors.primary : AppColors.onSurface,
          ),
        ),
      ],
    );
  }
}

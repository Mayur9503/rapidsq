import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../state/app_state_controller.dart';
import '../state/emergency_enums.dart';
import '../navigation/app_routes.dart';

class SosSearchingScreen extends StatefulWidget {
  final AppStateController controller;

  const SosSearchingScreen({
    super.key,
    required this.controller,
  });

  @override
  State<SosSearchingScreen> createState() => _SosSearchingScreenState();
}

class _SosSearchingScreenState extends State<SosSearchingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _radarController;

  @override
  void initState() {
    super.initState();
    _radarController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();

    widget.controller.addListener(_onStateChange);
  }

  void _onStateChange() {
    if (widget.controller.state == EmergencyState.ambulanceAssigned) {
      if (mounted) {
        Navigator.of(context).pushReplacementNamed(AppRoutes.ambulanceAssigned);
      }
    } else if (widget.controller.state == EmergencyState.errorState) {
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onStateChange);
    _radarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final location = widget.controller.userLocation;
    final profile = widget.controller.medicalProfile;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text('Triage Dispatching', style: TextStyle(fontWeight: FontWeight.w800)),
        centerTitle: false,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.errorContainer,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.emergency, color: AppColors.error, size: 14),
                SizedBox(width: 4),
                Text(
                  'PRIORITY 1',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: AppColors.error,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Active Transmission Banner
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Row(
                  children: [
                    Icon(Icons.wifi_tethering, color: Colors.white, size: 24),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'EMERGENCY DISPATCH INITIATED',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                          Text(
                            'Broadcasting telemetry to nearest ALS units',
                            style: TextStyle(fontSize: 11, color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      'BROADCASTING',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Radar Beacon Station
              SizedBox(
                width: 180,
                height: 180,
                child: AnimatedBuilder(
                  animation: _radarController,
                  builder: (context, child) {
                    final val = _radarController.value;
                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        // Expanding Ring 1
                        Container(
                          width: 180 * val,
                          height: 180 * val,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.primary.withValues(alpha: (1 - val) * 0.6),
                              width: 2,
                            ),
                          ),
                        ),
                        // Expanding Ring 2
                        Container(
                          width: 120 * ((val + 0.5) % 1.0),
                          height: 120 * ((val + 0.5) % 1.0),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.primary.withValues(alpha: (1 - ((val + 0.5) % 1.0)) * 0.5),
                              width: 2,
                            ),
                          ),
                        ),
                        // Center Pulse Core
                        Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primary,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.4),
                                blurRadius: 16,
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.emergency,
                              color: Colors.white,
                              size: 36,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),

              // Title & Description
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.amberContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.circle, color: AppColors.amber, size: 8),
                    SizedBox(width: 6),
                    Text(
                      'ACTIVE TRIAGE BEACON',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: AppColors.amber,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Finding nearest ambulance...',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Broadcasting high-priority triage beacon to 4 emergency vehicles within 3.2 km radius.',
                style: TextStyle(fontSize: 14, color: AppColors.secondary, height: 1.4),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // Telemetry Sync Card
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      child: Row(
                        children: [
                          Icon(Icons.cell_tower, color: AppColors.tertiary, size: 20),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Telemetry Signal Sync',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Row(
                      children: [
                        Container(
                          width: 4,
                          height: 12,
                          decoration: BoxDecoration(
                            color: AppColors.tertiary,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 2),
                        Container(
                          width: 4,
                          height: 16,
                          decoration: BoxDecoration(
                            color: AppColors.tertiary,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 2),
                        Container(
                          width: 4,
                          height: 20,
                          decoration: BoxDecoration(
                            color: AppColors.tertiary,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'OPTIMAL',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: AppColors.tertiary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Payload Details
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            'TRIAGE TRANSMISSION PAYLOAD',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: AppColors.secondary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(width: 8),
                        Text(
                          'AUTO-ENCRYPTED',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: AppColors.tertiary,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 20),
                    _buildPayloadRow('Dispatch Point', location.title),
                    const SizedBox(height: 6),
                    _buildPayloadRow('Patient Info', '${profile.fullName} (Age: ${profile.age}, Blood: ${profile.bloodGroup})'),
                    const SizedBox(height: 6),
                    _buildPayloadRow('Allergies', profile.allergies),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Fast-Track Action Button
              ElevatedButton.icon(
                onPressed: () {
                  widget.controller.assignAmbulance();
                  Navigator.of(context).pushReplacementNamed(AppRoutes.ambulanceAssigned);
                },
                icon: const Icon(Icons.check_circle, color: Colors.white, size: 20),
                label: const Text('FORCE AMBULANCE ASSIGNMENT'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.tertiary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(52),
                ),
              ),
              const SizedBox(height: 12),

              // Cancel Button
              OutlinedButton(
                onPressed: () {
                  widget.controller.cancelEmergency();
                  Navigator.of(context).pop();
                },
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                ),
                child: const Text('CANCEL REQUEST'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPayloadRow(String title, String val) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            title,
            style: const TextStyle(fontSize: 12, color: AppColors.secondary),
          ),
        ),
        Expanded(
          child: Text(
            val,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}

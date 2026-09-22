import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_colors.dart';
import '../state/app_state_controller.dart';
import '../state/app_mode.dart';
import '../state/emergency_enums.dart';
import '../navigation/app_routes.dart';
import '../models/emergency_request.dart';

class AmbulanceAssignedScreen extends StatelessWidget {
  final AppStateController controller;

  const AmbulanceAssignedScreen({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final unit = controller.assignedUnit;
    final req = controller.currentRequest;
    final serviceType = req?.serviceType ?? controller.selectedService;

    String screenTitle = 'Ambulance Assigned';
    String headerTitle = 'AMBULANCE DISPATCH CONFIRMED';
    String headerSubtitle = 'Paramedic unit en route with active siren';
    String unitBadge = unit.unitType.toUpperCase();
    String vehicleNumber = unit.vehicleNumber;
    String driverName = unit.driverName;
    String driverRole = 'Certified ALS Paramedic Driver';
    String destinationLabel = 'ASSIGNED DESTINATION HOSPITAL';
    String destinationValue = unit.hospitalName;
    IconData serviceIcon = Icons.emergency;
    IconData destinationIcon = Icons.local_hospital;
    Color themeColor = AppColors.primary;

    if (serviceType == EmergencyServiceType.womenSafety) {
      screenTitle = 'Safety Response Assigned';
      headerTitle = 'SAFETY PATROL DISPATCH CONFIRMED';
      headerSubtitle = 'Quick Response Patrol (QRT) en route with distress beacon';
      unitBadge = 'QUICK RESPONSE PATROL (QRT)';
      vehicleNumber = 'PATROL-108';
      driverName = 'Officer R. Verma (QRT)';
      driverRole = 'Civilian Safety Protection Specialist';
      destinationLabel = 'ASSIGNED SAFE HAVEN / POLICE POST';
      destinationValue = 'Sector 62 Police Post & Safe Haven';
      serviceIcon = Icons.shield;
      destinationIcon = Icons.security;
      themeColor = const Color(0xFF7C3AED);
    } else if (serviceType == EmergencyServiceType.fireBrigade) {
      screenTitle = 'Fire Brigade Assigned';
      headerTitle = 'FIRE BRIGADE DISPATCH CONFIRMED';
      headerSubtitle = 'Fire engine & heavy rescue squad en route with siren';
      unitBadge = 'FIRE ENGINE & RESCUE SQUAD';
      vehicleNumber = 'FIRE-05';
      driverName = 'Commander S. Negi';
      driverRole = 'Lead Fire Officer & Rescue Specialist';
      destinationLabel = 'FIRE STATION DISPATCH COMMAND';
      destinationValue = 'Sector 62 Central Fire Station';
      serviceIcon = Icons.local_fire_department;
      destinationIcon = Icons.fire_truck;
      themeColor = const Color(0xFFEA580C);
    }

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Text(screenTitle, style: const TextStyle(fontWeight: FontWeight.w800)),
        centerTitle: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Confirmed Unit Header Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: themeColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: themeColor.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                      child: Icon(Icons.check, color: themeColor, size: 28),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            headerTitle,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.6,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            headerSubtitle,
                            style: const TextStyle(fontSize: 12, color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Emergency Details Card
              if (req?.additionalNotes != null && req!.additionalNotes!.isNotEmpty) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.info_outline, color: themeColor, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${serviceType.displayName.toUpperCase()} DETAILS',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: themeColor,
                                letterSpacing: 0.6,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              req.additionalNotes!,
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Unit Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: themeColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(serviceIcon, color: themeColor, size: 30),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: themeColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  unitBadge,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    color: themeColor,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                vehicleNumber,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.0,
                                  color: AppColors.onSurface,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 28),

                    // ETA & Distance Metrics
                    Row(
                      children: [
                        _buildMetric('ESTIMATED ARRIVAL', '${unit.etaMinutes} MIN', isHighlight: true),
                        Container(width: 1, height: 40, color: AppColors.borderLight),
                        _buildMetric('DISTANCE', '${unit.distanceKm} KM'),
                        Container(width: 1, height: 40, color: AppColors.borderLight),
                        _buildMetric('TRAFFIC', 'CLEAR', isSuccess: true),
                      ],
                    ),
                    const Divider(height: 28),

                    // Driver Profile & Contact
                    Row(
                      children: [
                        const CircleAvatar(
                          radius: 22,
                          backgroundColor: AppColors.secondary,
                          child: Icon(Icons.person, color: Colors.white, size: 24),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                driverName,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.onSurface,
                                ),
                              ),
                              Text(
                                driverRole,
                                style: const TextStyle(fontSize: 12, color: AppColors.secondary),
                              ),
                            ],
                          ),
                        ),
                        IconButton.filled(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Calling $driverName...')),
                            );
                          },
                          icon: const Icon(Icons.phone, size: 20),
                          style: IconButton.styleFrom(
                            backgroundColor: AppColors.tertiary,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Destination Card
              Container(
                padding: const EdgeInsets.all(16),
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
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(destinationIcon, color: themeColor, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            destinationLabel,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.8,
                              color: AppColors.secondary,
                            ),
                          ),
                          Text(
                            destinationValue,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Primary Action: Google Maps in Firebase Mode, Live Tracking in Mock Mode
              controller.appMode == AppMode.firebase
                  ? ElevatedButton.icon(
                      onPressed: () async {
                        final lat = req?.location.latitude ?? controller.userLocation.latitude;
                        final lng = req?.location.longitude ?? controller.userLocation.longitude;
                        final uri = Uri.parse('https://www.google.com/maps/dir/?api=1&destination=$lat,$lng');
                        try {
                          if (await canLaunchUrl(uri)) {
                            await launchUrl(uri, mode: LaunchMode.externalApplication);
                          }
                        } catch (_) {}
                      },
                      icon: const Icon(Icons.map, color: Colors.white, size: 22),
                      label: const Text('OPEN DESTINATION IN GOOGLE MAPS'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(56),
                      ),
                    )
                  : ElevatedButton.icon(
                      onPressed: () {
                        controller.transitionTo(EmergencyState.enRoute);
                        Navigator.of(context).pushReplacementNamed(AppRoutes.liveTracking);
                      },
                      icon: const Icon(Icons.navigation, color: Colors.white, size: 22),
                      label: const Text('OPEN LIVE GPS TRACKING'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(56),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetric(String label, String val, {bool isHighlight = false, bool isSuccess = false}) {
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: AppColors.secondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            val,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: isHighlight
                  ? AppColors.primary
                  : isSuccess
                      ? AppColors.tertiary
                      : AppColors.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

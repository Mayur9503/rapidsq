import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../state/app_state_controller.dart';
import '../state/emergency_enums.dart';
import '../widgets/mock_map_view.dart';
import '../navigation/app_routes.dart';
import '../models/emergency_request.dart';

class LiveTrackingScreen extends StatefulWidget {
  final AppStateController controller;

  const LiveTrackingScreen({
    super.key,
    required this.controller,
  });

  @override
  State<LiveTrackingScreen> createState() => _LiveTrackingScreenState();
}

class _LiveTrackingScreenState extends State<LiveTrackingScreen> {
  int _timelineIndex = 2; // 0: SOS Sent, 1: Assigned, 2: On Way, 3: Arriving, 4: Arrived, 5: Completed

  List<String> get _stages {
    final serviceType = widget.controller.currentRequest?.serviceType ?? widget.controller.selectedService;
    final assignedTitle = serviceType == EmergencyServiceType.womenSafety
        ? 'Safety Unit Assigned'
        : serviceType == EmergencyServiceType.fireBrigade
            ? 'Fire Brigade Assigned'
            : 'Ambulance Assigned';

    return [
      'SOS Sent',
      assignedTitle,
      'On the Way',
      'Arriving',
      'Arrived',
      'Completed',
    ];
  }

  void _advanceTimeline() {
    setState(() {
      if (_timelineIndex < _stages.length - 1) {
        _timelineIndex++;
        if (_timelineIndex == 3) {
          widget.controller.transitionTo(EmergencyState.arriving);
        } else if (_timelineIndex == 4) {
          widget.controller.transitionTo(EmergencyState.arrived);
        } else if (_timelineIndex == 5) {
          widget.controller.transitionTo(EmergencyState.completed);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final unit = widget.controller.assignedUnit;
    final isCompleted = _timelineIndex == 5;
    final req = widget.controller.currentRequest;
    final serviceType = req?.serviceType ?? widget.controller.selectedService;

    final bannerMessage = isCompleted
        ? 'Emergency Response Handover Complete'
        : serviceType == EmergencyServiceType.womenSafety
            ? 'Safety Patrol Unit is rushing to your location'
            : serviceType == EmergencyServiceType.fireBrigade
                ? 'Fire Engine & Rescue Squad is rushing to your location'
                : 'Ambulance is rushing to your location';

    final responderTitle = serviceType == EmergencyServiceType.womenSafety
        ? 'Officer R. Verma (QRT)'
        : serviceType == EmergencyServiceType.fireBrigade
            ? 'Commander S. Negi'
            : unit.driverName;

    final vehicleSubtitle = serviceType == EmergencyServiceType.womenSafety
        ? 'PATROL-108 • Quick Response Patrol'
        : serviceType == EmergencyServiceType.fireBrigade
            ? 'FIRE-05 • Heavy Rescue Squad'
            : '${unit.vehicleNumber} • ${unit.unitType}';

    final serviceIcon = serviceType == EmergencyServiceType.womenSafety
        ? Icons.shield
        : serviceType == EmergencyServiceType.fireBrigade
            ? Icons.local_fire_department
            : Icons.medical_services;

    final themeColor = serviceType == EmergencyServiceType.womenSafety
        ? const Color(0xFF7C3AED)
        : serviceType == EmergencyServiceType.fireBrigade
            ? const Color(0xFFEA580C)
            : AppColors.primary;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text('Live Tracking', style: TextStyle(fontWeight: FontWeight.w800)),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: AppColors.onSurface),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Live telemetry tracking link copied')),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Map Canvas Area (Realistic mock map)
            MockMapView(
              etaMinutes: (_timelineIndex == 4 || _timelineIndex == 5) ? 0 : (_timelineIndex == 3 ? 1 : unit.etaMinutes),
              distanceKm: (_timelineIndex == 4 || _timelineIndex == 5) ? 0.0 : (_timelineIndex == 3 ? 0.3 : unit.distanceKm),
              statusText: _stages[_timelineIndex],
              height: 280,
            ),

            // Scrollable Operational Dispatch Bottom Sheet
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, -2),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Status Headline Banner
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isCompleted
                              ? AppColors.tertiaryFixed.withValues(alpha: 0.4)
                              : themeColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isCompleted ? AppColors.tertiary : themeColor,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                bannerMessage,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.onSurface,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Driver & Unit Card
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundColor: themeColor.withValues(alpha: 0.15),
                            child: Icon(serviceIcon, color: themeColor),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  responderTitle,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.onSurface,
                                  ),
                                ),
                                Text(
                                  vehicleSubtitle,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.secondary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton.filled(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Calling driver: ${unit.driverPhone}')),
                              );
                            },
                            icon: const Icon(Icons.call, size: 20),
                            style: IconButton.styleFrom(
                              backgroundColor: AppColors.tertiary,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 28),

                      // Status Timeline
                      const Text(
                        'DISPATCH TIMELINE',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                          color: AppColors.secondary,
                        ),
                      ),
                      const SizedBox(height: 12),

                      ...List.generate(_stages.length, (index) {
                        final isPassed = index <= _timelineIndex;
                        final isCurrent = index == _timelineIndex;

                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              children: [
                                Container(
                                  width: 18,
                                  height: 18,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isPassed ? AppColors.tertiary : AppColors.surfaceContainerHighest,
                                    border: isCurrent
                                        ? Border.all(color: AppColors.primary, width: 2)
                                        : null,
                                  ),
                                  child: isPassed
                                      ? const Icon(Icons.check, size: 12, color: Colors.white)
                                      : null,
                                ),
                                if (index < _stages.length - 1)
                                  Container(
                                    width: 2,
                                    height: 24,
                                    color: isPassed ? AppColors.tertiary : AppColors.surfaceContainerHighest,
                                  ),
                              ],
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _stages[index],
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: isCurrent ? FontWeight.w800 : FontWeight.w500,
                                  color: isPassed ? AppColors.onSurface : AppColors.secondary,
                                ),
                              ),
                            ),
                            if (isCurrent)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryFixed,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'CURRENT',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                          ],
                        );
                      }),
                      const SizedBox(height: 24),

                      // Interactive Simulation Controls for Demo
                      if (!isCompleted) ...[
                        ElevatedButton.icon(
                          onPressed: _advanceTimeline,
                          icon: const Icon(Icons.fast_forward, size: 20, color: Colors.white),
                          label: Text(
                            _timelineIndex == 4 ? 'COMPLETE EMERGENCY' : 'ADVANCE STATUS (${_stages[(_timelineIndex + 1).clamp(0, 5)]})',
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            minimumSize: const Size.fromHeight(52),
                          ),
                        ),
                        const SizedBox(height: 10),
                        OutlinedButton(
                          onPressed: () {
                            widget.controller.cancelEmergency();
                            Navigator.of(context).pop();
                          },
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(48),
                          ),
                          child: const Text('CANCEL DISPATCH'),
                        ),
                      ] else ...[
                        ElevatedButton.icon(
                          onPressed: () {
                            widget.controller.resetToIdle();
                            Navigator.of(context).pushNamedAndRemoveUntil(
                              AppRoutes.mainScaffold,
                              (route) => false,
                            );
                          },
                          icon: const Icon(Icons.home, color: Colors.white),
                          label: const Text('RETURN TO HOME'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.tertiary,
                            foregroundColor: Colors.white,
                            minimumSize: const Size.fromHeight(56),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

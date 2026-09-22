import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_colors.dart';
import '../state/app_state_controller.dart';
import '../state/app_mode.dart';
import '../navigation/app_routes.dart';
import '../widgets/dev_control_bar.dart';
import '../models/emergency_request.dart';

class AmbulanceDriverScreen extends StatefulWidget {
  final AppStateController controller;

  const AmbulanceDriverScreen({
    super.key,
    required this.controller,
  });

  @override
  State<AmbulanceDriverScreen> createState() => _AmbulanceDriverScreenState();
}

class _AmbulanceDriverScreenState extends State<AmbulanceDriverScreen> {
  bool _isResponding = false;
  Timer? _countdownTimer;
  int _remainingSeconds = 6;
  bool _hasExpired = false;
  String? _trackedIncidentId;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_syncDriverState);
    _syncDriverState();
  }

  @override
  void dispose() {
    widget.controller.removeListener(_syncDriverState);
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _syncDriverState() {
    final status = widget.controller.ambulanceStatus;
    final incident = widget.controller.currentRequest;

    if (status == 'OFFERED') {
      final id = incident?.id ?? 'pending-offer';
      if (_trackedIncidentId != id) {
        _trackedIncidentId = id;
        _startCountdown(incident);
      }
    } else {
      if (_trackedIncidentId != null) {
        _trackedIncidentId = null;
        _countdownTimer?.cancel();
        _countdownTimer = null;
      }
      if (status == 'AVAILABLE') {
        _hasExpired = false;
        _remainingSeconds = 6;
      }
    }
  }

  void _startCountdown(EmergencyRequest? incident) {
    _countdownTimer?.cancel();
    final now = DateTime.now();
    int initial = incident?.acceptanceTimeoutSeconds ?? 6;
    if (incident?.offerExpiresAt != null) {
      final diff = incident!.offerExpiresAt!.difference(now).inSeconds;
      initial = diff.clamp(0, incident.acceptanceTimeoutSeconds);
    }

    if (initial <= 0) {
      setState(() {
        _remainingSeconds = 0;
        _hasExpired = true;
      });
      return;
    }

    setState(() {
      _remainingSeconds = initial;
      _hasExpired = false;
    });

    _playAlertPulse();

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_remainingSeconds <= 1) {
        timer.cancel();
        setState(() {
          _remainingSeconds = 0;
          _hasExpired = true;
        });
        _handleAutoExpire();
      } else {
        setState(() {
          _remainingSeconds--;
        });
        _playAlertPulse();
      }
    });
  }

  void _playAlertPulse() {
    try {
      SystemSound.play(SystemSoundType.alert);
      HapticFeedback.heavyImpact();
    } catch (_) {}
  }

  void _handleAutoExpire() {
    if (widget.controller.ambulanceStatus == 'OFFERED') {
      _handleDriverResponse('REJECT', isTimeout: true);
    }
  }

  Future<void> _launchNavigationToPatient(double lat, double lng) async {
    // 1. Direct native Google Maps Android turn-by-turn navigation intent
    final navAppUri = Uri.parse('google.navigation:q=$lat,$lng&mode=d');
    // 2. Native Android geo intent targeting installed map applications
    final geoUri = Uri.parse('geo:$lat,$lng?q=$lat,$lng');
    // 3. Universal Web Fallback URL
    final webMapsUri = Uri.parse('https://www.google.com/maps/dir/?api=1&destination=$lat,$lng');

    try {
      if (await canLaunchUrl(navAppUri)) {
        await launchUrl(navAppUri, mode: LaunchMode.externalNonBrowserApplication);
        return;
      }
    } catch (_) {}

    try {
      if (await canLaunchUrl(geoUri)) {
        await launchUrl(geoUri, mode: LaunchMode.externalNonBrowserApplication);
        return;
      }
    } catch (_) {}

    try {
      if (await canLaunchUrl(webMapsUri)) {
        await launchUrl(webMapsUri, mode: LaunchMode.externalApplication);
        return;
      }
    } catch (_) {}

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Destination coordinates: $lat, $lng')),
      );
    }
  }

  Future<void> _handleDriverResponse(String action, {bool isTimeout = false}) async {
    _countdownTimer?.cancel();
    setState(() => _isResponding = true);
    try {
      await widget.controller.respondToIncomingEmergency(action);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: action == 'ACCEPT' ? AppColors.tertiary : AppColors.primary,
            content: Text(
              action == 'ACCEPT'
                  ? 'Dispatch Accepted! Route assigned to Unit #402.'
                  : (isTimeout
                      ? 'Offer expired: 6-second acceptance window passed.'
                      : 'Emergency offer rejected.'),
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.error,
            content: Text('Error: $e'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isResponding = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        final unit = widget.controller.assignedUnit;
        final driverStatus = widget.controller.ambulanceStatus;
        final incident = widget.controller.currentRequest;
        final patientLat = incident?.location.latitude ?? 28.6280;
        final patientLng = incident?.location.longitude ?? 77.3649;
        final serviceType = incident?.serviceType ?? widget.controller.selectedService;

        return Scaffold(
          backgroundColor: AppColors.surface,
          appBar: AppBar(
            title: const Row(
              children: [
                Icon(Icons.local_shipping, color: AppColors.primary, size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'AMBULANCE / RIDER TERMINAL',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900),
                      ),
                      Text(
                        'Ambulance Terminal (Unit #402)',
                        style: TextStyle(fontSize: 10, color: AppColors.secondary, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              Container(
                margin: const EdgeInsets.only(right: 6),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusBgColor(driverStatus),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _getStatusColor(driverStatus), width: 1.5),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _getStatusColor(driverStatus),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      driverStatus.toUpperCase(),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: _getStatusColor(driverStatus),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.logout, color: AppColors.error, size: 20),
                tooltip: 'Logout',
                onPressed: () async {
                  await widget.controller.signOut();
                  if (context.mounted) {
                    Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.auth, (route) => false);
                  }
                },
              ),
            ],
          ),
          bottomSheet: widget.controller.appMode == AppMode.mock
              ? DevControlBar(controller: widget.controller)
              : null,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Unit Profile Card
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
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppColors.primaryFixed,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.emergency, color: AppColors.primary, size: 28),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${unit.driverName} • ${unit.vehicleNumber}',
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${unit.unitType} • Fortis Trauma Center',
                                style: const TextStyle(fontSize: 12, color: AppColors.secondary),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Incoming Emergency Alert Card
                  if (incident != null || driverStatus == 'OFFERED' || driverStatus == 'BUSY') ...[
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: driverStatus == 'BUSY'
                            ? AppColors.primary.withValues(alpha: 0.05)
                            : AppColors.secondaryFixed.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: driverStatus == 'BUSY' ? AppColors.primary : AppColors.secondary,
                          width: 2,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    Icon(
                                      driverStatus == 'BUSY' ? Icons.check_circle : Icons.warning_amber_rounded,
                                      color: driverStatus == 'BUSY' ? AppColors.primary : AppColors.onSecondaryFixed,
                                      size: 22,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        (serviceType == EmergencyServiceType.womenSafety)
                                            ? (driverStatus == 'BUSY' ? 'ACTIVE WOMEN SAFETY RUN' : 'INCOMING WOMEN SAFETY OFFER')
                                            : (serviceType == EmergencyServiceType.fireBrigade)
                                                ? (driverStatus == 'BUSY' ? 'ACTIVE FIRE BRIGADE RUN' : 'INCOMING FIRE BRIGADE OFFER')
                                                : (driverStatus == 'BUSY' ? 'ACTIVE EMERGENCY DISPATCH' : 'INCOMING EMERGENCY OFFER'),
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: 0.8,
                                          color: driverStatus == 'BUSY' ? AppColors.primary : AppColors.onSecondaryFixed,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  serviceType.displayName.toUpperCase(),
                                  style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                          if (driverStatus != 'BUSY') ...[
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              decoration: BoxDecoration(
                                color: _hasExpired
                                    ? AppColors.errorContainer
                                    : (_remainingSeconds <= 2 ? AppColors.errorContainer : AppColors.amberContainer),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _hasExpired
                                      ? AppColors.error
                                      : (_remainingSeconds <= 2 ? AppColors.error : AppColors.amber),
                                  width: 1.5,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Row(
                                        children: [
                                          Text('🚨', style: TextStyle(fontSize: 18)),
                                          SizedBox(width: 6),
                                          Text(
                                            'NEW EMERGENCY',
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w900,
                                              color: AppColors.primary,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: _hasExpired || _remainingSeconds <= 2 ? AppColors.error : AppColors.amber,
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          '${_remainingSeconds}s',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w900,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${serviceType.displayName} Required',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.onSurface,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _hasExpired
                                        ? 'Offer Expired (0s)'
                                        : 'Accept in $_remainingSeconds seconds',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w800,
                                      color: _hasExpired || _remainingSeconds <= 2
                                          ? AppColors.error
                                          : AppColors.amber,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    '6 → 5 → 4 → 3 → 2 → 1',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                      color: (_hasExpired || _remainingSeconds <= 2
                                              ? AppColors.error
                                              : AppColors.amber)
                                          .withValues(alpha: 0.9),
                                      letterSpacing: 1.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          if (driverStatus == 'BUSY') ...[
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: AppColors.tertiary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppColors.tertiary.withValues(alpha: 0.3)),
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.check_circle, color: AppColors.tertiary, size: 20),
                                  SizedBox(width: 8),
                                  Text(
                                    '✓ Emergency Accepted',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.tertiary,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          const Divider(height: 24),
                          const Text(
                            'Location:',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.secondary),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Latitude: ${patientLat.toStringAsFixed(5)}\nLongitude: ${patientLng.toStringAsFixed(5)}',
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            incident?.location.title ?? 'Emergency Location',
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                          ),
                          if (incident?.location.subtitle != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              incident!.location.subtitle,
                              style: const TextStyle(fontSize: 12, color: AppColors.secondary),
                            ),
                          ],
                          const SizedBox(height: 8),
                          Text(
                            'Description: ${incident?.additionalNotes ?? "Urgent emergency assistance requested"}',
                            style: const TextStyle(fontSize: 13, color: AppColors.secondary, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const Icon(Icons.my_location, size: 16, color: AppColors.secondary),
                              const SizedBox(width: 6),
                              Text(
                                'GPS: ${patientLat.toStringAsFixed(4)}, ${patientLng.toStringAsFixed(4)}',
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Offer Actions (Accept / Reject)
                          if (driverStatus != 'BUSY') ...[
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: _isResponding ? null : () => _handleDriverResponse('REJECT'),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: AppColors.primary,
                                      side: const BorderSide(color: AppColors.primary, width: 1.5),
                                      minimumSize: const Size.fromHeight(50),
                                    ),
                                    child: const Text('REJECT', style: TextStyle(fontWeight: FontWeight.w800)),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  flex: 2,
                                  child: ElevatedButton.icon(
                                    onPressed: (_isResponding || _hasExpired)
                                        ? null
                                        : () => _handleDriverResponse('ACCEPT'),
                                    icon: const Icon(Icons.check_circle, color: Colors.white),
                                    label: Text(
                                      _hasExpired ? 'EXPIRED' : 'ACCEPT DISPATCH',
                                      style: const TextStyle(fontWeight: FontWeight.w800),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: _hasExpired ? Colors.grey : AppColors.tertiary,
                                      foregroundColor: Colors.white,
                                      minimumSize: const Size.fromHeight(50),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],

                          // Assigned Active Actions
                          if (driverStatus == 'BUSY') ...[
                            ElevatedButton.icon(
                              onPressed: () => _launchNavigationToPatient(patientLat, patientLng),
                              icon: const Icon(Icons.navigation, color: Colors.white),
                              label: const Text('Open Google Maps', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                minimumSize: const Size.fromHeight(54),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                            const SizedBox(height: 10),
                            OutlinedButton.icon(
                              onPressed: () {
                                widget.controller.completeEmergencyAsDriver();
                              },
                              icon: const Icon(Icons.done_all, color: AppColors.tertiary),
                              label: const Text(
                                'MARK PATIENT ONBOARD & COMPLETE',
                                style: TextStyle(color: AppColors.tertiary, fontWeight: FontWeight.w800),
                              ),
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size.fromHeight(48),
                                side: const BorderSide(color: AppColors.tertiary),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ] else ...[
                    // Idle Standby Card
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.borderLight),
                      ),
                      child: const Column(
                        children: [
                          Icon(Icons.radar, size: 48, color: AppColors.tertiary),
                          SizedBox(height: 12),
                          Text(
                            'STANDBY • READY FOR DISPATCH',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, letterSpacing: 0.8),
                          ),
                          SizedBox(height: 6),
                          Text(
                            'No active emergency',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.onSurface),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Waiting for emergency requests...',
                            style: TextStyle(fontSize: 13, color: AppColors.secondary, fontWeight: FontWeight.w600),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Listening to ambulances/main for real-time incoming emergency SOS beacons.',
                            style: TextStyle(fontSize: 11, color: AppColors.secondary),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 20),

                  // Static Incident GPS Coordinates Info Box (Live tracking not required)
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
                          children: [
                            Icon(Icons.location_pin, size: 16, color: AppColors.secondary),
                            SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'PATIENT GPS COORDINATES (CAPTURED AT SOS)',
                                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.secondary),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                'Lat: ${patientLat.toStringAsFixed(4)}, Lng: ${patientLng.toStringAsFixed(4)}',
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.tertiaryFixed.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'STATIC GPS',
                                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.tertiary),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Driver taps "Open Google Maps" to navigate using the initial GPS fix. Continuous tracking is disabled.',
                          style: TextStyle(fontSize: 11, color: AppColors.secondary),
                        ),
                      ],
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

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'AVAILABLE':
        return AppColors.tertiary;
      case 'OFFERED':
        return Colors.orange.shade800;
      case 'BUSY':
        return AppColors.primary;
      default:
        return AppColors.secondary;
    }
  }

  Color _getStatusBgColor(String status) {
    return _getStatusColor(status).withValues(alpha: 0.12);
  }
}
